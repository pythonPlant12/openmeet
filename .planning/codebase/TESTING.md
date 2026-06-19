---
type: codebase-map
focus: quality
artifact: testing
analysis_date: 2026-06-19
---

# Testing Patterns

**Analysis Date:** 2026-06-19

## Test Framework

**Runner:**
- Client unit/component tests use Vitest `^3.2.4` from `openmeet-client/package.json`.
- Client DOM tests run in `jsdom` through `openmeet-client/vitest.config.ts`.
- Client browser tests use Vitest Browser mode with Playwright provider and Firefox in `openmeet-client/vitest.browser.config.ts`.
- Client E2E is configured for Playwright `^1.56.1` in `openmeet-client/playwright.config.ts`, but no `openmeet-client/e2e/` tests are present.
- Server tests use Rust `cargo test` from `.github/workflows/test.yml`; no dedicated `openmeet-server/tests/` integration test files are present.

**Assertion Library:**
- Vitest `expect` for client tests, imported from `vitest` in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts` and `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Playwright `expect` is available through `@playwright/test` for future E2E tests configured by `openmeet-client/playwright.config.ts`.
- Rust uses the built-in Rust test harness, but no explicit `#[test]` or `#[tokio::test]` tests were detected under `openmeet-server/src/` or `openmeet-server/tests/`.

**Run Commands:**
```bash
cd openmeet-client && yarn test:unit --run        # Run client Vitest unit/component tests once
cd openmeet-client && yarn test:unit              # Run client Vitest in default/watch-capable mode
cd openmeet-client && yarn test:browser           # Run Vitest browser tests with vitest.browser.config.ts
cd openmeet-client && yarn test:e2e               # Run Playwright E2E tests from openmeet-client/e2e when present
cd openmeet-client && yarn type-check             # Run vue-tsc --build
cd openmeet-client && yarn lint                   # Run oxlint and eslint fix/check flow
cd openmeet-server && cargo test                  # Run server Rust tests
cd openmeet-server && cargo check                 # Type/check server code
```

## Test File Organization

**Location:**
- Unit/component tests are co-located in `__tests__` directories below the code under test.
- Auth composable tests live at `openmeet-client/src/composables/__tests__/useAuth.test.ts` and `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts` beside `openmeet-client/src/composables/useAuth.ts`.
- Auth state-machine tests live at `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts` beside `openmeet-client/src/xstate/machines/auth/index.ts` and `openmeet-client/src/xstate/machines/auth/types.ts`.
- Playwright expects E2E tests in `openmeet-client/e2e/` by `testDir: './e2e'` in `openmeet-client/playwright.config.ts`; this directory is not present.
- Server tests are expected either inline in Rust modules or under `openmeet-server/tests/`; no Rust test files were detected.

**Naming:**
- Unit/component tests use `*.test.ts`, for example `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Browser-mode Vitest tests use `*.browser.test.ts`, for example `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts`.
- Playwright E2E tests should use `*.test.ts` or `*.spec.ts` under `openmeet-client/e2e/`, matching the ESLint Playwright file pattern in `openmeet-client/eslint.config.ts` and `testDir` in `openmeet-client/playwright.config.ts`.

**Structure:**
```text
openmeet-client/src/
├── composables/
│   ├── useAuth.ts
│   └── __tests__/
│       ├── useAuth.test.ts
│       └── useAuth.browser.test.ts
└── xstate/machines/auth/
    ├── index.ts
    ├── types.ts
    └── __tests__/
        └── auth.machine.test.ts
```

## Test Structure

**Suite Organization:**
```typescript
describe('Auth Machine', () => {
  let actor: ReturnType<typeof createActor<typeof authMachine>>;

  afterEach(() => {
    actor?.stop();
    vi.clearAllMocks();
  });

  describe('Login Flow', () => {
    beforeEach(() => {
      actor = createActor(authMachine, {
        input: { initialAccessToken: null, initialRefreshToken: null, router: mockRouter },
      });
      actor.start();
    });

    it('should successfully authenticate with valid credentials', async () => {
      await waitFor(actor, (state) => state.matches(AuthState.UNAUTHENTICATED));
      actor.send({ type: AuthEventType.LOGIN, email: 'test@test.com', password: 'password' });
      await waitFor(actor, (state) => state.matches(AuthState.AUTHENTICATED), { timeout: 2000 });
      expect(actor.getSnapshot().value).toBe(AuthState.AUTHENTICATED);
    });
  });
});
```

**Patterns:**
- Use nested `describe(...)` blocks to group by behavior/state area, as in `Initial State - No Token`, `Login Flow`, `Logout Flow`, and `Token Refresh` in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Use `beforeEach(...)` to create and start a fresh XState actor per state-flow group in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Use `afterEach(...)` to stop actors and clear mocks in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Use `waitFor(actor, predicate, { timeout })` from XState for asynchronous state transitions instead of arbitrary sleeps in state-machine tests.
- Use `mount(...)` from `@vue/test-utils` for composable/component tests in `openmeet-client/src/composables/__tests__/useAuth.test.ts` and `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts`.
- Expose observable state through `data-testid` attributes in synthetic test components, as in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.

## Mocking

**Framework:**
- Vitest `vi` for module mocks, spies, and mock functions.
- Vue Test Utils `global.provide` for dependency injection in mounted components.
- XState `createActor` and `waitFor` for machine execution.

**Patterns:**
```typescript
const mockRouter: Router = {
  push: vi.fn(),
} as any;

vi.mock('@/utils', () => ({
  cookieUtils: {
    get: vi.fn(),
    set: vi.fn(),
    remove: vi.fn(),
  },
}));

vi.mock('@/services/auth-api', () => ({
  authApi: {
    login: vi.fn().mockImplementation(async ({ email, password }) => {
      if (email === 'test@test.com' && password === 'password') {
        return {
          user: { id: '1', email, name: 'Test User', role: 'user' },
          access_token: 'mock-access-token',
          refresh_token: 'mock-refresh-token',
        };
      }
      throw new Error('Invalid credentials');
    }),
    refresh: vi.fn().mockResolvedValue({ access_token: 'new-access-token' }),
    logout: vi.fn().mockResolvedValue(undefined),
  },
}));
```

**What to Mock:**
- Mock router navigation with a minimal `Router` object that includes `push: vi.fn()`, as in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Mock storage/cookie helpers at the module boundary, as `@/utils` is mocked in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Mock API services at the module boundary, as `@/services/auth-api` is mocked in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Provide injected app actors via Vue Test Utils `global.provide`, as `authActor` is provided in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.

**What NOT to Mock:**
- Do not mock the auth machine when testing auth state transitions; instantiate the real `authMachine` with `createActor(...)` in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Do not mock `useAuth()` when testing the composable; mount a small component that calls the real composable, as in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Do not mock Vue reactivity for composable tests; assert computed refs and rendered text from a mounted component in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Do not mock browser rendering for files ending in `*.browser.test.ts`; these are excluded from `openmeet-client/vitest.config.ts` and intended for `openmeet-client/vitest.browser.config.ts`.

## Fixtures and Factories

**Test Data:**
```typescript
function createAuthTestWrapper(initialAccessToken: string | null = null) {
  const authActorRef = useMachine(authMachine, {
    input: { initialAccessToken, initialRefreshToken: initialAccessToken ? 'mock-refresh-token' : null },
  });

  const TestComponent = defineComponent({
    setup() {
      const auth = useAuth();
      return { auth };
    },
    render() {
      return h('div', [
        h('div', { 'data-testid': 'state' }, this.auth.state.value?.value || ''),
        h('div', { 'data-testid': 'is-authenticated' }, String(this.auth.isAuthenticated.value)),
      ]);
    },
  });

  const wrapper = mount(TestComponent, {
    global: { provide: { authActor: authActorRef } },
  });

  return { wrapper, authActorRef };
}
```

**Location:**
- Fixtures/factories are inline in the test file that uses them. `createAuthTestWrapper()` lives in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Auth API mock responses are inline in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- No shared fixture directory is present under `openmeet-client/src/` or `openmeet-server/`.

## Coverage

**Requirements:**
- No coverage threshold is enforced in `openmeet-client/vitest.config.ts`.
- No coverage script is defined in `openmeet-client/package.json`.
- CI runs lint and unit tests for the client and cargo tests/checks for the server in `.github/workflows/test.yml`, but does not collect or upload coverage.

**View Coverage:**
```bash
cd openmeet-client && yarn vitest --coverage     # Not a package script; requires coverage provider support if added
cd openmeet-server && cargo test                 # Runs tests; coverage tooling is not configured
```

## Test Types

**Unit Tests:**
- Client unit tests cover XState auth-machine behavior in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`.
- Auth-machine tests assert initial state, login, logout, token refresh, context clearing, router integration, and failure recovery with mocked API and cookie modules.
- Server unit tests are not detected; add Rust `#[cfg(test)]` modules near pure logic or integration tests under `openmeet-server/tests/` when server behavior is changed.

**Component/Composable Tests:**
- Vue composable tests mount a synthetic component that calls the real composable and renders computed values in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Tests assert dependency-injection failure, computed state exposure, boolean helpers, current user, actor methods, and reactivity in `openmeet-client/src/composables/__tests__/useAuth.test.ts`.
- Browser-mode component integration is represented by `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts`, which mounts a wrapper that provides `authActor` and renders a login page.

**Integration Tests:**
- Client integration-level coverage is limited to XState flows with mocked external modules in `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts` and the browser-mode auth flow in `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts`.
- Server integration tests for Axum routes, Diesel persistence, WebSocket signaling, and SFU room behavior are not present.

**E2E Tests:**
- Playwright is configured in `openmeet-client/playwright.config.ts` with Chromium, Firefox, and WebKit projects.
- Playwright uses `baseURL` `http://localhost:5173` locally and `http://localhost:4173` on CI, configured in `openmeet-client/playwright.config.ts`.
- Playwright starts `npm run dev` locally and `npm run preview` on CI via `webServer` in `openmeet-client/playwright.config.ts`.
- No `openmeet-client/e2e/` tests were detected; add user journey tests there when browser-level behavior needs coverage.

## Common Patterns

**Async Testing:**
```typescript
actor.send({
  type: AuthEventType.LOGIN,
  email: 'test@test.com',
  password: 'password',
});

await waitFor(actor, (state) => state.matches(AuthState.AUTHENTICATED), { timeout: 2000 });
expect(actor.getSnapshot().context.accessToken).toBe('mock-access-token');
```

**Error Testing:**
```typescript
expect(() => {
  mount(TestComponent);
}).toThrow('Auth actor not provided');

actor.send({
  type: AuthEventType.LOGIN,
  email: 'wrong@test.com',
  password: 'wrongpassword',
});

await waitFor(actor, (state) => state.matches(AuthState.AUTHENTICATION_FAILED), { timeout: 2000 });
expect(actor.getSnapshot().context.error).toBe('Invalid credentials');
```

**DOM Testing:**
```typescript
const { wrapper } = createAuthTestWrapper();
expect(wrapper.find('[data-testid="state"]').text()).toBeTruthy();
expect(wrapper.vm.auth.isAuthenticated).toBeDefined();
```

**Browser Testing:**
```typescript
const wrapper = mount(WrapperComponent);
const emailInput = wrapper.find('#email');
const passwordInput = wrapper.find('#password');
await emailInput.setValue('test@test.com');
await passwordInput.setValue('password');
await wrapper.find('form').trigger('submit');
```

**CI Testing Flow:**
- Build workflow `.github/workflows/build.yml` runs client `yarn type-check` and `yarn build`, then server `cargo check --release` and `cargo build --release`.
- Test workflow `.github/workflows/test.yml` runs after Build succeeds and executes client `yarn lint`, client `yarn test:unit --run`, server `cargo test`, and server `cargo check`.
- Deploy workflow `.github/workflows/deploy.yml` runs only after Test succeeds.

---

*Testing analysis: 2026-06-19*
