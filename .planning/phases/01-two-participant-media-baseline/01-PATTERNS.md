# Phase 01: Two-Participant Media Baseline - Pattern Map

**Mapped:** 2026-06-27
**Files analyzed:** 14
**Analogs found:** 14 / 14

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `openmeet-client/src/services/signaling.ts` | service | event-driven WebSocket | `openmeet-client/src/services/signaling.ts` | exact-self |
| `openmeet-client/src/services/webrtc-sfu.ts` | service | streaming WebRTC | `openmeet-client/src/services/webrtc-sfu.ts` | exact-self |
| `openmeet-client/src/xstate/machines/webrtc/index.ts` | state machine | event-driven | `openmeet-client/src/xstate/machines/webrtc/index.ts` | exact-self |
| `openmeet-client/src/xstate/machines/webrtc/actors.ts` | actor/provider | event-driven side effects | `openmeet-client/src/xstate/machines/webrtc/actors.ts` | exact-self |
| `openmeet-client/src/xstate/machines/webrtc/types.ts` | type contract | event-driven | `openmeet-client/src/xstate/machines/webrtc/types.ts` | exact-self |
| `openmeet-client/src/pages/MeetingPage.vue` | page component | UI state/rendering | `openmeet-client/src/pages/MeetingPage.vue` | exact-self |
| `openmeet-client/src/components/meeting-page/ConnectionErrorDialog.vue` | component | request-response UI action | `openmeet-client/src/components/meeting-page/ConnectionErrorDialog.vue` | exact-self |
| `openmeet-client/src/components/meeting-page/ParticipantTile.vue` | component | streaming media render | `openmeet-client/src/components/meeting-page/ParticipantTile.vue` | exact-self |
| `openmeet-client/src/components/meeting-page/VideoGrid.vue` | component | UI state/rendering | `openmeet-client/src/components/meeting-page/VideoGrid.vue` | exact-self |
| `openmeet-server/src/signaling/handler.rs` | WebSocket handler | event-driven request-response | `openmeet-server/src/signaling/handler.rs` | exact-self |
| `openmeet-server/src/signaling/message.rs` | protocol contract | serialization | `openmeet-server/src/signaling/message.rs` | exact-self |
| `openmeet-server/src/sfu/room.rs` | service/domain model | streaming RTP fan-out | `openmeet-server/src/sfu/room.rs` | exact-self |
| `openmeet-server/src/sfu/peer_connection.rs` | service wrapper | WebRTC request-response/streaming | `openmeet-server/src/sfu/peer_connection.rs` | exact-self |
| `openmeet-client/e2e/multi-participant-media.spec.ts` | test | browser streaming E2E | `openmeet-client/e2e/multi-participant-media.spec.ts` | exact-self |

## Pattern Assignments

### `openmeet-client/src/services/signaling.ts` (service, event-driven WebSocket)

**Analog:** `openmeet-client/src/services/signaling.ts`

**Protocol union pattern** (lines 3-20):
```typescript
export type SignalingMessage =
  | { type: 'join'; roomId: string; participantName: string }
  | { type: 'joined'; participantId: string; participantName: string }
  | { type: 'offer'; targetId: string; sdp: string }
  | { type: 'answer'; targetId: string; sdp: string }
  | {
      type: 'iceCandidate';
      targetId: string;
      candidate: string;
      sdpMid: string | null;
      sdpMLineIndex: number | null;
    }
  | { type: 'participantJoined'; participantId: string; participantName: string }
  | { type: 'participantLeft'; participantId: string }
  | { type: 'streamOwner'; streamId: string; participantId: string; participantName: string }
  | { type: 'mediaStateChanged'; participantId: string; audioEnabled: boolean; videoEnabled: boolean }
  | { type: 'chatMessage'; participantId: string; participantName: string; message: string; timestamp: number }
  | { type: 'error'; message: string };
```

**Connection/reconnect pattern** (lines 34-66, 175-192):
```typescript
connect(): Promise<void> {
  return new Promise((resolve, reject) => {
    console.log('[SignalingService] Connecting to:', this.serverUrl);
    this.ws = new WebSocket(this.serverUrl);

    this.ws.onopen = () => {
      console.log('[SignalingService] WebSocket connected');
      this.reconnectAttempts = 0;
      this.intentionalDisconnect = false;
      resolve();
    };

    this.ws.onclose = () => {
      console.log('[SignalingService] WebSocket closed');
      this.handleDisconnect();
    };
  });
}

private handleDisconnect(): void {
  if (this.intentionalDisconnect) return;
  if (this.reconnectAttempts < this.maxReconnectAttempts) {
    this.reconnectAttempts++;
    console.log(`[SignalingService] Reconnecting (attempt ${this.reconnectAttempts})...`);
    setTimeout(() => {
      this.connect().catch((error) => {
        console.error('[SignalingService] Reconnect failed:', error);
      });
    }, this.reconnectDelay * this.reconnectAttempts);
  } else {
    console.error('[SignalingService] Max reconnect attempts reached');
  }
}
```

**Handler registration/cleanup pattern** (lines 144-160, 162-172):
```typescript
on(messageType: string, handler: MessageHandler): void {
  if (!this.messageHandlers.has(messageType)) {
    this.messageHandlers.set(messageType, []);
  }
  this.messageHandlers.get(messageType)!.push(handler);
}

off(messageType: string, handler: MessageHandler): void {
  const handlers = this.messageHandlers.get(messageType);
  if (handlers) {
    const index = handlers.indexOf(handler);
    if (index > -1) handlers.splice(index, 1);
  }
}
```

**Apply:** Add terminal disconnect/reconnect-exhaustion reporting through this service rather than ad hoc page polling. Keep diagnostic logs tagged `[SignalingService]` and secret-free.

---

### `openmeet-client/src/services/webrtc-sfu.ts` (service, streaming WebRTC)

**Analog:** `openmeet-client/src/services/webrtc-sfu.ts`

**Imports/env pattern** (lines 1-19):
```typescript
import { resolveReachableTurnUrl } from './dev-networking';
import { SignalingService } from './signaling';

function createDefaultIceServers(): RTCIceServer[] {
  return [
    { urls: ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302'] },
    {
      urls: [resolveReachableTurnUrl(import.meta.env.VITE_TURN_URL || 'turn:turn.openmeets.eu:3478')],
      username: import.meta.env.VITE_TURN_USER || 'openmeet',
      credential: import.meta.env.VITE_TURN_PASSWORD || 'openmeet123',
    },
  ];
}
```

**Media initialization pattern** (lines 68-106):
```typescript
async initializeMedia(deviceConstraints?: DeviceConstraints): Promise<MediaStream> {
  try {
    const audioConstraints: MediaTrackConstraints = {
      echoCancellation: true,
      noiseSuppression: true,
      autoGainControl: true,
    };
    const videoConstraints: MediaTrackConstraints = {
      width: { ideal: 640, max: 640 },
      height: { ideal: 360, max: 360 },
      frameRate: { ideal: 15, max: 15 },
    };
    this.localStream = await navigator.mediaDevices.getUserMedia({ video: videoConstraints, audio: audioConstraints });
    console.log('[WebRTCServiceSFU] Media initialized:', {
      audioTracks: this.localStream.getAudioTracks().length,
      videoTracks: this.localStream.getVideoTracks().length,
    });
    return this.localStream;
  } catch (error) {
    throw new Error(`Failed to access media devices: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}
```

**Peer connection and remote-track pattern** (lines 109-163):
```typescript
this.peerConnection = new RTCPeerConnection({
  iceServers: this.iceServers,
  iceCandidatePoolSize: 10,
});

this.localStream.getTracks().forEach((track) => {
  this.peerConnection!.addTrack(track, this.localStream!);
});

this.peerConnection.onicecandidate = (event) => {
  if (event.candidate) {
    this.signalingService.sendIceCandidate('server', event.candidate.toJSON());
  }
};

this.peerConnection.ontrack = (event) => {
  const stream = event.streams[0];
  const track = event.track;
  console.log(`[WebRTCServiceSFU] ✓ Received ${track.kind} track from stream ${stream.id} (muted: ${track.muted})`);
  if (this.localStream && stream.id === this.localStream.id) return;
  if (stream && this.onRemoteTrackCallback) {
    this.onRemoteTrackCallback(stream.id, stream);
  }
};
```

**Negotiation pattern** (lines 170-222):
```typescript
const offer = await this.peerConnection.createOffer();
await this.peerConnection.setLocalDescription(offer);
this.signalingService.sendOffer('server', offer.sdp!);

const offerDescription = new RTCSessionDescription({ type: 'offer', sdp });
await this.peerConnection.setRemoteDescription(offerDescription);
const answer = await this.peerConnection.createAnswer();
await this.peerConnection.setLocalDescription(answer);
this.signalingService.sendAnswer('server', answer.sdp!);
```

**Apply:** Add diagnostics around `signalingState`, track IDs, stream IDs, ICE state, and connection state here. Do not print SDP/TURN credentials.

---

### `openmeet-client/src/xstate/machines/webrtc/index.ts` (state machine, event-driven)

**Analog:** `openmeet-client/src/xstate/machines/webrtc/index.ts`

**Context/import pattern** (lines 1-23):
```typescript
import { assign, setup } from 'xstate';

import type { DeviceConstraints } from '@/services/webrtc-sfu';

import { clearServices, getServices, getSignalingService, initMediaActor, joinRoomActor } from './actors';
import type { ChatMessage, Participant, SFUContext, SFUEvents } from './types';

const initialContext: SFUContext = {
  localStream: null,
  participants: new Map(),
  localParticipantId: null,
  localParticipantName: '',
  roomId: null,
  connectionState: null,
  iceConnectionState: null,
  streamOwnerMap: new Map(),
  chatMessages: [],
  error: null,
};
```

**Stream-owner assignment pattern to fix/guard** (lines 88-124):
```typescript
setStreamOwner: assign({
  streamOwnerMap: ({ context }, params: { streamId: string; participantId: string }) => {
    const newMap = new Map(context.streamOwnerMap);
    newMap.set(params.streamId, params.participantId);
    return newMap;
  },
}),

assignStreamToParticipant: assign({
  participants: ({ context }, params: { streamId: string; stream: MediaStream }) => {
    const newParticipants = new Map(context.participants);
    const ownerParticipantId = context.streamOwnerMap.get(params.streamId);
    if (ownerParticipantId) {
      const participant = newParticipants.get(ownerParticipantId);
      if (participant) {
        console.log('[webrtcMachine] Assigning stream to:', participant.name);
        newParticipants.set(ownerParticipantId, { ...participant, stream: params.stream });
      }
    } else {
      const participantWithoutStream = Array.from(newParticipants.values()).find((p) => !p.isLocal && !p.stream);
      if (participantWithoutStream) {
        console.log('[webrtcMachine] Fallback: Assigning stream to:', participantWithoutStream.name);
        newParticipants.set(participantWithoutStream.id, { ...participantWithoutStream, stream: params.stream });
      }
    }
    return newParticipants;
  },
}),
```

**Terminal error transition pattern** (lines 389-427, 456-466):
```typescript
CONNECTION_STATE_CHANGED: [
  {
    guard: ({ event }) => event.state === 'failed',
    target: '#webrtcMachine.error',
    actions: [
      { type: 'setConnectionState', params: ({ event }) => ({ state: event.state }) },
      { type: 'setError', params: ({ event }) => ({ error: `Connection ${event.state}` }) },
      'cleanup',
    ],
  },
  { actions: [{ type: 'setConnectionState', params: ({ event }) => ({ state: event.state }) }] },
]

error: {
  on: {
    RETRY: { target: 'idle', actions: ['cleanup', 'resetContext'] },
    LEAVE_ROOM: { target: 'idle', actions: ['cleanup', 'resetContext'] },
  },
}
```

**Apply:** Route WebSocket terminal failures into machine events like `SERVER_ERROR` or a new typed event. Keep transient `disconnected` in connected state.

---

### `openmeet-client/src/xstate/machines/webrtc/actors.ts` (actor/provider, event-driven side effects)

**Analog:** `openmeet-client/src/xstate/machines/webrtc/actors.ts`

**Service singleton pattern** (lines 1-30):
```typescript
import { fromCallback, fromPromise } from 'xstate';

import { resolveReachableWebSocketUrl } from '@/services/dev-networking';
import { SignalingService } from '@/services/signaling';
import { WebRTCServiceSFU } from '@/services/webrtc-sfu';

const SFU_SERVER_URL = resolveReachableWebSocketUrl(import.meta.env.VITE_SFU_WSS_URL || 'wss://sfu.openmeets.eu/ws');

let signalingService: SignalingService | null = null;
let webrtcService: WebRTCServiceSFU | null = null;
```

**Callback actor event bridge pattern** (lines 58-80, 127-144):
```typescript
export const joinRoomActor = fromCallback<SFUEvents, JoinRoomInput>(({ sendBack, input }) => {
  if (!signalingService || !webrtcService) {
    sendBack({ type: 'SERVER_ERROR', message: 'Services not initialized. Call initMedia first' });
    return;
  }

  signalingService.on('joined', (message) => {
    if (message.type === 'joined') {
      sendBack({ type: 'JOINED', participantId: message.participantId, participantName: message.participantName });
    }
  });

  signalingService.on('streamOwner', (message) => {
    if (message.type === 'streamOwner') {
      sendBack({ type: 'STREAM_OWNER', streamId: message.streamId, participantId: message.participantId, participantName: message.participantName });
    }
  });

  webrtcService.setOnRemoteTrack((streamId, stream) => {
    console.log('[webrtcMachine] Remote track received:', streamId);
    sendBack({ type: 'REMOTE_TRACK_RECEIVED', streamId, stream });
  });
});
```

**Connection-state bridge pattern** (lines 149-168):
```typescript
const pc = webrtcService.createPeerConnection();

pc.onconnectionstatechange = () => {
  sendBack({ type: 'CONNECTION_STATE_CHANGED', state: pc.connectionState });
};

pc.oniceconnectionstatechange = () => {
  sendBack({ type: 'ICE_CONNECTION_STATE_CHANGED', state: pc.iceConnectionState });
};

webrtcService.sendOffer().catch((error) => {
  sendBack({ type: 'SERVER_ERROR', message: error instanceof Error ? error.message : 'Failed to send offer' });
});
```

**Apply:** If adding signaling callbacks, register named handlers and call `signalingService.off(...)` in the returned cleanup to avoid duplicate event delivery.

---

### `openmeet-client/src/xstate/machines/webrtc/types.ts` (type contract, event-driven)

**Analog:** `openmeet-client/src/xstate/machines/webrtc/types.ts`

**Context/event shape pattern** (lines 19-43, 55-75):
```typescript
export interface SFUContext {
  localStream: MediaStream | null;
  participants: Map<string, Participant>;
  localParticipantId: string | null;
  localParticipantName: string;
  roomId: string | null;
  connectionState: RTCPeerConnectionState | null;
  iceConnectionState: RTCIceConnectionState | null;
  streamOwnerMap: Map<string, string>;
  chatMessages: ChatMessage[];
  error: string | null;
}

export type SFUSignalingEvents =
  | { type: 'JOINED'; participantId: string; participantName: string }
  | { type: 'PARTICIPANT_JOINED'; participantId: string; participantName: string }
  | { type: 'PARTICIPANT_LEFT'; participantId: string }
  | { type: 'STREAM_OWNER'; streamId: string; participantId: string; participantName: string }
  | { type: 'SERVER_ERROR'; message: string };
```

**Apply:** Any new terminal disconnect event should be explicit in this union. Do not store large SDP/media payloads in machine context.

---

### `openmeet-client/src/pages/MeetingPage.vue` (page component, UI state/rendering)

**Analog:** `openmeet-client/src/pages/MeetingPage.vue`

**Imports/composable pattern** (lines 1-13, 24-41):
```typescript
import { Users } from 'lucide-vue-next';
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

import ChatPanel from '@/components/meeting-page/ChatPanel.vue';
import ConnectionErrorDialog from '@/components/meeting-page/ConnectionErrorDialog.vue';
import JoinMeetingDialog from '@/components/meeting-page/JoinMeetingDialog.vue';
import MeetingControls from '@/components/meeting-page/MeetingControls.vue';
import VideoGrid from '@/components/meeting-page/VideoGrid.vue';
import { useWebrtc } from '@/composables/useWebrtc';

const { connectionState, iceConnectionState, state, error: webrtcError, initMedia, joinRoom, leaveRoom: endCall } = useWebrtc();
```

**Error visibility pattern** (lines 86-96, 142-147, 376-382):
```typescript
watch(
  () => state.value,
  (newState) => {
    if (newState === 'error' && webrtcError.value) {
      console.error('[MeetingRoom] WebRTC error:', webrtcError.value.message);
      showJoinDialog.value = true;
      participantName.value = '';
    }
  },
);

watch(connectionState, (newState) => {
  if (newState === 'failed') {
    showConnectionError.value = true;
  }
});

<ConnectionErrorDialog
  :open="showConnectionError"
  :connection-state="connectionState"
  @leave="handleEndCall"
  @close="showConnectionError = false"
/>
```

**Debug/status panel pattern** (lines 297-338):
```vue
<div v-if="showConnectionStatus" class="fixed top-20 right-4 z-50 bg-card border border-border rounded-lg p-3 text-xs space-y-1">
  <div class="flex items-center gap-2">
    <span class="text-muted-foreground">State:</span>
    <span class="font-mono text-primary">{{ state }}</span>
  </div>
  <div class="flex items-center gap-2">
    <span class="text-muted-foreground">Connection:</span>
    <span class="font-mono">{{ connectionState || 'none' }}</span>
  </div>
  <div class="flex items-center gap-2">
    <span class="text-muted-foreground">ICE:</span>
    <span class="font-mono">{{ iceConnectionState || 'none' }}</span>
  </div>
</div>
```

**Apply:** Extend the existing error dialog trigger and debug panel; do not add new UI surfaces. Use UI-SPEC copy: `Your connection to the meeting was lost. Reload the page to reconnect, or leave the meeting and join again.`

---

### `openmeet-client/src/components/meeting-page/ConnectionErrorDialog.vue` (component, request-response UI action)

**Analog:** `openmeet-client/src/components/meeting-page/ConnectionErrorDialog.vue`

**shadcn-vue dialog import pattern** (lines 1-12):
```typescript
import { AlertTriangle } from 'lucide-vue-next';

import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
```

**Props/emits/action pattern** (lines 14-38):
```typescript
interface Props {
  open: boolean;
  connectionState?: string | null;
}

defineProps<Props>();

const emit = defineEmits<{
  (e: 'reload'): void;
  (e: 'leave'): void;
  (e: 'close'): void;
}>();

const handleReload = () => {
  emit('reload');
  window.location.reload();
};
```

**Dialog structure pattern** (lines 41-66):
```vue
<Dialog :open="open" @update:open="(val) => !val && handleClose()">
  <DialogContent class="sm:max-w-md">
    <div data-testid="connection-error-dialog">
      <DialogHeader>
        <div class="flex items-center gap-3">
          <div class="p-2 bg-destructive/10 rounded-full">
            <AlertTriangle class="h-6 w-6 text-destructive" />
          </div>
          <DialogTitle>Connection Lost</DialogTitle>
        </div>
        <DialogDescription class="pt-2">...</DialogDescription>
      </DialogHeader>
      <DialogFooter class="flex-col sm:flex-row gap-2">
        <Button variant="outline" data-testid="connection-error-leave" @click="handleLeave"> Leave Meeting </Button>
        <Button data-testid="connection-error-reload" @click="handleReload"> Reload Page </Button>
      </DialogFooter>
    </div>
  </DialogContent>
</Dialog>
```

**Apply:** Keep destructive warning styling and existing button labels. Update copy only; do not expose internal diagnostics in UI.

---

### `openmeet-client/src/components/meeting-page/ParticipantTile.vue` (component, streaming media render)

**Analog:** `openmeet-client/src/components/meeting-page/ParticipantTile.vue`

**Stream attach/playback pattern** (lines 24-38, 68-84):
```typescript
const videoRef = ref<HTMLVideoElement | null>(null);

const playAttachedVideo = async () => {
  const video = videoRef.value;
  if (!video || !props.participant.stream) return;
  try {
    await video.play();
  } catch {
    console.log(`[ParticipantTile] Autoplay may be blocked for ${props.participant.name}`);
  }
};

const attachStream = async () => {
  await nextTick();
  if (videoRef.value && props.participant.stream) {
    if (videoRef.value.srcObject !== props.participant.stream) {
      console.log(`[ParticipantTile] Attaching stream for ${props.participant.name}`);
      videoRef.value.srcObject = props.participant.stream;
    }
    props.participant.stream.getTracks().forEach((track) => {
      track.onunmute = () => void playAttachedVideo();
    });
    await playAttachedVideo();
  }
};
```

**Video element pattern** (lines 119-136):
```vue
<video
  v-if="participant.stream"
  ref="videoRef"
  data-testid="participant-video"
  :data-participant-id="participant.id"
  :data-participant-local="participant.isLocal"
  autoplay
  playsinline
  :muted="participant.isLocal"
  @loadedmetadata="playAttachedVideo"
  @canplay="playAttachedVideo"
  :class="['w-full h-full rounded-lg bg-[hsl(0,0%,12%)]', objectFitClass, { hidden: !participant.videoEnabled, '-scale-x-100': participant.isLocal }]"
/>
```

**Apply:** Use the existing `data-testid` and `data-participant-*` attributes for Playwright verification. Keep video element mounted when stream exists so audio can play.

---

### `openmeet-server/src/signaling/handler.rs` (WebSocket handler, event-driven request-response)

**Analog:** `openmeet-server/src/signaling/handler.rs`

**Imports/logging pattern** (lines 1-24):
```rust
use axum::{
    extract::{
        ws::{Message, WebSocket},
        State, WebSocketUpgrade,
    },
    response::Response,
};
use futures_util::{SinkExt, StreamExt};
use metrics::{counter, gauge};
use std::sync::Arc;
use tokio::sync::mpsc;
use tracing::{error, info, warn};
```

**WebSocket send/receive task pattern** (lines 34-64, 74-109):
```rust
async fn handle_socket(socket: WebSocket, room_repo: Arc<dyn RoomRepository>) {
    let (mut sender, mut receiver) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel::<SignalingMessage>();
    let participant_id = Uuid::new_v4().to_string();
    info!("New WebSocket connection: {}", participant_id);

    let mut send_task = tokio::spawn(async move {
        while let Some(message) = rx.recv().await {
            match serde_json::to_string(&message) {
                Ok(json) => {
                    if let Err(e) = sender.send(Message::Text(json.into())).await {
                        error!("✗ Send failed to {}: {}", participant_id_for_logging, e);
                        break;
                    }
                }
                Err(e) => error!("✗ Serialize failed for {}: {}", participant_id_for_logging, e),
            }
        }
    });
}
```

**Join and peer-connection setup pattern** (lines 160-220, 229-294):
```rust
info!("Participant {} ({}) joining room {}", name, participant_id, room_id);

let mut config = PeerConnectionConfig::default();
if let Ok(ip) = std::env::var("PUBLIC_IP") {
    if !ip.is_empty() {
        config = config.with_public_ip(ip);
    }
}
if let (Ok(turn_url), Ok(turn_user), Ok(turn_password)) = (
    std::env::var("TURN_URL"),
    std::env::var("TURN_USER"),
    std::env::var("TURN_PASSWORD"),
) {
    if !turn_url.is_empty() && !turn_user.is_empty() {
        info!("Configuring TURN server: {}", turn_url);
        config = config.with_turn_server(turn_url, turn_user, turn_password);
    }
}

match SfuPeerConnection::new(participant_id.to_string(), config).await {
    Ok(peer_conn) => {
        counter!("sfu_peer_connections_created_total").increment(1);
        participant_conn.set_peer_connection(peer_conn);
    }
    Err(e) => {
        error!("Failed to create peer connection for {}: {}", participant_id, e);
        let _ = tx.send(SignalingMessage::Error { message: format!("Failed to create peer connection: {}", e) });
        return;
    }
}
```

**Known lock anti-pattern to replace** (lines 269-289):
```rust
pc.on_track(move |track, receiver| {
    let room_lock = Arc::clone(&room_lock_clone);
    let participant_id = participant_id_clone.clone();
    let sender_pc = Arc::clone(&sender_peer_connection);

    tokio::spawn(async move {
        let mut room = room_lock.write().await;
        room.handle_incoming_track(&participant_id, track, receiver, sender_pc).await;
    });
});
```

**Apply:** Preserve Axum/mpsc task shape, but do not await long WebRTC operations while holding `room_lock.write()`. Snapshot room state, release lock, then add tracks/negotiate.

---

### `openmeet-server/src/signaling/message.rs` (protocol contract, serialization)

**Analog:** `openmeet-server/src/signaling/message.rs`

**Serde enum pattern** (lines 1-6, 57-85):
```rust
use serde::{Deserialize, Serialize};

/// Messages sent between client and server for WebRTC signaling
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum SignalingMessage {
    /// Maps a stream ID to its owner participant
    #[serde(rename_all = "camelCase")]
    StreamOwner {
        stream_id: String,
        participant_id: String,
        participant_name: String,
    },

    /// Error message from server
    Error {
        message: String,
    },
}
```

**Contract test pattern** (lines 88-117):
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_serialize_join_message() {
        let msg = SignalingMessage::Join {
            room_id: "room123".to_string(),
            participant_name: "Alice".to_string(),
        };
        let json = serde_json::to_string(&msg).unwrap();
        assert!(json.contains("\"type\":\"join\""));
        assert!(json.contains("\"roomId\":\"room123\""));
    }
}
```

**Apply:** Any new message must be mirrored in `openmeet-client/src/services/signaling.ts` and covered by serde tests.

---

### `openmeet-server/src/sfu/room.rs` (service/domain model, streaming RTP fan-out)

**Analog:** `openmeet-server/src/sfu/room.rs`

**Imports and room state pattern** (lines 1-20, 57-66):
```rust
use std::collections::HashMap;
use std::collections::HashSet;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::sync::broadcast;
use tracing::{ info, warn, error, debug };

pub struct Room {
    pub id: String,
    pub participants: HashMap<String, ParticipantConnection>,
    pub participant_tracks: HashMap<String, Vec<SenderTrackInfo>>,
    pub negotiated_tracks: Arc<RwLock<HashMap<String, HashSet<String>>>>,
}
```

**Participant and broadcast pattern** (lines 79-95, 177-203):
```rust
pub fn add_participant(&mut self, participant: ParticipantConnection) {
    let participant_id = participant.participant.id.clone();
    let participant_name = participant.participant.name.clone();
    info!("Adding participant {} ({}) to room {}", participant_name, participant_id, self.id);
    self.participants.insert(participant_id.clone(), participant);
    self.broadcast_except(&participant_id, SignalingMessage::ParticipantJoined {
        participant_id: participant_id.clone(),
        participant_name,
    });
}

pub fn broadcast_except(&self, exclude_id: &str, message: SignalingMessage) {
    for (id, participant) in &self.participants {
        if id != exclude_id {
            if let Err(e) = participant.send(message.clone()) {
                warn!("Failed to send message to participant {}: {}", id, e);
            }
        }
    }
}
```

**Track registration/fan-out pattern to refactor safely** (lines 226-265, 286-366):
```rust
pub async fn handle_incoming_track(
    &mut self,
    participant_id: &str,
    track: Arc<TrackRemote>,
    _receiver: Arc<RTCRtpReceiver>,
    sender_peer_connection: Arc<RTCPeerConnection>,
) {
    let track_kind = track.kind();
    let track_id = track.stream_id();
    let sender_ssrc = track.ssrc();
    info!("Room {}: Participant {} sent {} track (stream_id: {}, ssrc: {})", self.id, participant_id, track_kind, track_id, sender_ssrc);

    let (packet_tx, _) = broadcast::channel::<RtpPacket>(RTP_BROADCAST_CAPACITY);
    self.participant_tracks.entry(participant_id.to_string()).or_insert_with(Vec::new).push(track_info);
    self.forward_track_to_others(participant_id, track, sender_peer_connection, packet_tx).await;
}

let _ = participant_conn.send(SignalingMessage::StreamOwner {
    stream_id: stream_id.clone(),
    participant_id: sender_id.to_string(),
    participant_name: sender_name.clone(),
});

match pc.add_track(Arc::clone(&local_track) as Arc<dyn TrackLocal + Send + Sync>).await {
    Ok(rtp_sender) => { /* get SSRC, spawn renegotiation, writer tasks */ }
    Err(e) => error!("Failed to add track to {}: {}", participant_id, e),
}
```

**RTP reader/writer task pattern** (lines 380-413, 450-511):
```rust
tokio::spawn(async move {
    let mut packet_count = 0u64;
    loop {
        match track.read_rtp().await {
            Ok((rtp_packet, _)) => {
                packet_count += 1;
                if packet_count % 500 == 0 {
                    info!("Read {} {} packets FROM {}", packet_count, track_kind, from_id);
                }
                let _ = packet_tx_clone.send(rtp_packet);
            }
            Err(_) => break,
        }
    }
});

tokio::spawn(async move {
    loop {
        tokio::select! {
            _ = shutdown_rx.changed() => break,
            result = packet_rx.recv() => {
                match result {
                    Ok(mut rtp_packet) => {
                        rtp_packet.header.ssrc = local_ssrc;
                        packet_buffer.store(&rtp_packet).await;
                        if let Err(e) = local_track.write_rtp(&rtp_packet).await { warn!("Write error: {}", e); }
                    }
                    Err(broadcast::error::RecvError::Closed) => break,
                    Err(broadcast::error::RecvError::Lagged(n)) => warn!("Receiver {} lagged {} packets from {}", to_id, n, from_id),
                }
            }
        }
    }
});
```

**Apply:** Keep broadcast-channel reader/writer topology and `StreamOwner` before receiver track addition. Refactor by introducing snapshot structs/helpers if needed, but keep Phase 1 scoped to two participants.

---

### `openmeet-server/src/sfu/peer_connection.rs` (service wrapper, WebRTC request-response/streaming)

**Analog:** `openmeet-server/src/sfu/peer_connection.rs`

**Config builder pattern** (lines 21-79):
```rust
#[derive(Clone)]
pub struct PeerConnectionConfig {
    pub ice_servers: Vec<RTCIceServer>,
    pub public_ip: Option<String>,
    pub udp_port_range: Option<(u16, u16)>,
}

impl PeerConnectionConfig {
    pub fn with_public_ip(mut self, public_ip: String) -> Self {
        self.public_ip = Some(public_ip);
        self
    }

    pub fn with_turn_server(mut self, url: String, username: String, credential: String) -> Self {
        self.ice_servers.push(RTCIceServer { urls: vec![url], username, credential, ..Default::default() });
        self
    }
}
```

**Connection state logging pattern** (lines 150-196):
```rust
peer_connection.on_ice_connection_state_change(Box::new(move |state: RTCIceConnectionState| {
    let participant_id = participant_id_clone.clone();
    Box::pin(async move {
        info!("Participant {} ICE connection state: {:?}", participant_id, state);
        match state {
            RTCIceConnectionState::Failed | RTCIceConnectionState::Disconnected => {
                warn!("Participant {} connection issues: {:?}", participant_id, state);
            }
            RTCIceConnectionState::Connected | RTCIceConnectionState::Completed => {
                info!("Participant {} successfully connected", participant_id);
            }
            _ => {}
        }
    })
}));
```

**Negotiation guard pattern** (lines 198-259):
```rust
pub async fn set_remote_description(&self, sdp: String, sdp_type: &str) -> Result<()> {
    let session_description = match sdp_type {
        "offer" => RTCSessionDescription::offer(sdp)?,
        "answer" => RTCSessionDescription::answer(sdp)?,
        _ => return Err(anyhow::anyhow!("Invalid SDP type: {}", sdp_type)),
    };
    self.peer_connection.set_remote_description(session_description).await?;
    Ok(())
}

pub async fn create_offer_if_stable(&self) -> Result<Option<RTCSessionDescription>> {
    let signaling_state = self.peer_connection.signaling_state();
    if signaling_state != webrtc::peer_connection::signaling_state::RTCSignalingState::Stable {
        info!("Participant {} signaling state is {:?}, skipping renegotiation offer to avoid collision", self.participant_id, signaling_state);
        return Ok(None);
    }
    let offer = self.peer_connection.create_offer(None).await?;
    self.peer_connection.set_local_description(offer.clone()).await?;
    Ok(Some(offer))
}
```

**Apply:** Preserve stable-state guard. Add diagnostics/pending retry only if reproduction shows skipped renegotiation.

---

### `openmeet-client/e2e/multi-participant-media.spec.ts` (test, browser streaming E2E)

**Analog:** `openmeet-client/e2e/multi-participant-media.spec.ts`

**Playwright fake media pattern** (lines 1-55):
```typescript
import { type Browser, type BrowserContext, type Page, expect, test } from '@playwright/test';

test.use({
  launchOptions: {
    args: [
      '--use-fake-device-for-media-stream',
      '--use-fake-ui-for-media-stream',
      '--autoplay-policy=no-user-gesture-required',
    ],
  },
});
```

**Participant context isolation pattern** (lines 155-193):
```typescript
async function joinParticipants(browser: Browser, baseURL: string, count: number, roomPrefix: string): Promise<ParticipantSession> {
  const roomUrl = `${baseURL}/room/${roomPrefix}-${Date.now()}`;
  const contexts: BrowserContext[] = [];
  const pages: Page[] = [];

  for (let index = 0; index < count; index += 1) {
    const context = await browser.newContext({ permissions: ['camera', 'microphone'] });
    contexts.push(context);
    pages.push(await context.newPage());
  }

  for (const [index, page] of pages.entries()) {
    await page.goto(roomUrl, { waitUntil: 'domcontentloaded' });
    await page.locator('#participant-name').fill(`User ${index + 1}`);
    await expect(page.getByRole('button', { name: 'Join Meeting' })).toBeEnabled({ timeout: 30_000 });
    await page.getByRole('button', { name: 'Join Meeting' }).click();
    await expect(page.getByTestId('participant-video').first()).toBeAttached({ timeout: 30_000 });
  }
  return { contexts, pages, roomUrl };
}
```

**Media verification pattern** (lines 204-221, 223-251, 253-319):
```typescript
async function waitForAllConnections(pages: Page[]) {
  await Promise.all(pages.map((page) =>
    page.waitForFunction(() => {
      const pc = window.__openmeetPeerConnections?.[0];
      return pc?.connectionState === 'connected' && pc.iceConnectionState === 'connected' && pc.signalingState === 'stable';
    }, null, { timeout: 60_000 }),
  ));
}

async function waitForHtmlVideoPlayback(pages: Page[], expectedParticipants: number) {
  await Promise.all(pages.map((page) =>
    page.waitForFunction((count) => {
      const videos = Array.from(document.querySelectorAll<HTMLVideoElement>('[data-testid="participant-video"]'));
      const remoteVideos = videos.filter((video) => video.dataset.participantLocal !== 'true');
      return videos.length === count && remoteVideos.length === count - 1 && remoteVideos.every((video) => {
        const stream = video.srcObject instanceof MediaStream ? video.srcObject : null;
        return stream !== null && stream.getVideoTracks().some((track) => track.readyState === 'live') && video.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA;
      });
    }, expectedParticipants, { timeout: 60_000 }),
  ));
}
```

**Apply:** For Phase 1, narrow or add a two-participant smoke that asserts both participants receive remote audio/video. Avoid making 3-4 participant stability a blocker.

## Shared Patterns

### Signaling contract alignment
**Sources:** `openmeet-client/src/services/signaling.ts` lines 3-20; `openmeet-server/src/signaling/message.rs` lines 3-85  
**Apply to:** Any new WebSocket message, disconnect event, diagnostic payload.

Keep TypeScript union and Rust serde enum in lockstep. Use camelCase JSON fields and bounded string payloads.

### User-visible terminal error flow
**Sources:** `openmeet-client/src/xstate/machines/webrtc/index.ts` lines 389-427; `openmeet-client/src/pages/MeetingPage.vue` lines 142-147; `ConnectionErrorDialog.vue` lines 41-66  
**Apply to:** Peer connection `failed`, WebSocket unexpected close/reconnect exhaustion.

Route terminal failures to the machine/page dialog, not just console logs. Transient `disconnected` remains diagnostic.

### Secret-free diagnostics
**Sources:** `AGENTS.md` logging constraints; `webrtc-sfu.ts` tagged logs lines 96-101, 146-159; `handler.rs` tracing lines 160-163, 338-343  
**Apply to:** Client/server instrumentation.

Use tagged client logs (`[WebRTCServiceSFU]`, `[SignalingService]`, `[webrtcMachine]`) and Rust `tracing::{info,warn,error}`. Do not log SDP bodies, token/cookie values, raw TURN credentials, or env files.

### Room-lock safety
**Sources:** `handler.rs` lines 283-287; `room.rs` lines 226-265 and 286-366  
**Apply to:** Server forwarding fixes.

Current code holds a room write lock across `handle_incoming_track().await`; Phase 1 fixes should snapshot room state under lock and release before awaiting peer connection locks, `add_track`, `get_parameters`, `write_rtcp`, or offer creation.

### Media rendering verification
**Sources:** `ParticipantTile.vue` lines 119-136; `multi-participant-media.spec.ts` lines 223-251 and 253-319  
**Apply to:** Browser smoke and regression tests.

Use `data-testid="participant-video"`, `data-participant-local`, WebRTC stats, `readyState`, video dimensions, and packet counters to prove remote audio/video is flowing.

## No Analog Found

No files lacked an analog. Phase 1 should modify existing meeting/signaling/SFU paths and tests rather than introduce broad new subsystems.

## Metadata

**Analog search scope:** `openmeet-client/src/services`, `openmeet-client/src/xstate/machines/webrtc`, `openmeet-client/src/pages`, `openmeet-client/src/components/meeting-page`, `openmeet-client/e2e`, `openmeet-server/src/signaling`, `openmeet-server/src/sfu`  
**Files scanned:** 20+ via phase artifacts, project instructions, globs, and direct reads  
**Pattern extraction date:** 2026-06-27
