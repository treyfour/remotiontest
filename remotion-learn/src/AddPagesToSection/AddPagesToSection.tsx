import React from "react";
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
  spring,
  Easing,
} from "remotion";
import { z } from "zod";
import { Cursor } from "./Cursor";
import { FileIcon } from "./FileIcon";
import { Modal } from "./Modal";
import { ThumbnailGrid } from "./ThumbnailGrid";
import { Button } from "./Button";
import { Section } from "./Section";

export const addPagesToSectionSchema = z.object({
  selectedPages: z.array(z.number()).default([0, 4]),
});

// Timeline constants (in frames at 30fps)
const TIMELINE = {
  // Scene 1: File appears, cursor moves
  FILE_APPEAR: 0,
  CURSOR_APPEAR: 15,
  CURSOR_REACH_FILE: 30,

  // Scene 2: Click and modal opens
  FILE_CLICK: 35,
  MODAL_OPEN: 45,

  // Scene 3: Select thumbnails
  SELECTION_START: 60,

  // Scene 4: Click add button
  BUTTON_HIGHLIGHT: 100,
  BUTTON_CLICK: 105,

  // Scene 5: Modal closes, then section appears (sequential, not overlapped)
  MODAL_CLOSE: 108,
  SECTION_APPEAR: 116, // Appears shortly after modal is gone (3 frame close + small gap)

  // Scene 6: Hold
  END: 180,
};

export const AddPagesToSection: React.FC<
  z.infer<typeof addPagesToSectionSchema>
> = ({ selectedPages }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Cursor positions calculated from modal layout:
  // Modal centered at (960, 540), padding 32px
  // Grid: 3x3, thumbnails 120x160px, gap 16px
  // Grid starts at x=764, y=269
  // Selected indices [0, 2, 4] = top-left, top-right, middle-center
  const cursorPositions = {
    start: { x: 1400, y: 200 },
    file: { x: 960, y: 450 },           // Target the file icon (above the text label)
    thumb0: { x: 824, y: 349 },         // Index 0: row 0, col 0
    thumb2: { x: 1096, y: 349 },        // Index 2: row 0, col 2
    thumb4: { x: 960, y: 525 },         // Index 4: row 1, col 1
    button: { x: 1050, y: 830 },        // "Add to Section" button (centered on button)
  };

  // Calculate cursor position based on frame
  let cursorX = cursorPositions.start.x;
  let cursorY = cursorPositions.start.y;
  let isClicking = false;

  if (frame < TIMELINE.CURSOR_REACH_FILE) {
    // Moving to file
    const progress = interpolate(
      frame,
      [TIMELINE.CURSOR_APPEAR, TIMELINE.CURSOR_REACH_FILE],
      [0, 1],
      { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) }
    );
    cursorX = interpolate(progress, [0, 1], [cursorPositions.start.x, cursorPositions.file.x]);
    cursorY = interpolate(progress, [0, 1], [cursorPositions.start.y, cursorPositions.file.y]);
  } else if (frame < TIMELINE.MODAL_OPEN) {
    // At file, clicking
    cursorX = cursorPositions.file.x;
    cursorY = cursorPositions.file.y;
    isClicking = frame >= TIMELINE.FILE_CLICK && frame < TIMELINE.FILE_CLICK + 5;
  } else if (frame < TIMELINE.SELECTION_START) {
    // Moving to first thumbnail (index 0)
    const progress = interpolate(
      frame,
      [TIMELINE.MODAL_OPEN, TIMELINE.SELECTION_START],
      [0, 1],
      { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) }
    );
    cursorX = interpolate(progress, [0, 1], [cursorPositions.file.x, cursorPositions.thumb0.x]);
    cursorY = interpolate(progress, [0, 1], [cursorPositions.file.y, cursorPositions.thumb0.y]);
  } else if (frame < TIMELINE.SELECTION_START + 8) {
    // At first thumbnail (index 0), clicking
    cursorX = cursorPositions.thumb0.x;
    cursorY = cursorPositions.thumb0.y;
    isClicking = frame >= TIMELINE.SELECTION_START && frame < TIMELINE.SELECTION_START + 3;
  } else if (frame < TIMELINE.SELECTION_START + 15) {
    // Moving to second thumbnail (index 4) - arrive by frame 75
    const progress = interpolate(
      frame,
      [TIMELINE.SELECTION_START + 8, TIMELINE.SELECTION_START + 15],
      [0, 1],
      { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) }
    );
    cursorX = interpolate(progress, [0, 1], [cursorPositions.thumb0.x, cursorPositions.thumb4.x]);
    cursorY = interpolate(progress, [0, 1], [cursorPositions.thumb0.y, cursorPositions.thumb4.y]);
  } else if (frame < TIMELINE.SELECTION_START + 25) {
    // At thumb4, clicking at frame 75
    cursorX = cursorPositions.thumb4.x;
    cursorY = cursorPositions.thumb4.y;
    isClicking = frame >= TIMELINE.SELECTION_START + 15 && frame < TIMELINE.SELECTION_START + 18;
  } else if (frame < TIMELINE.BUTTON_HIGHLIGHT) {
    // Move from thumb4 to button
    const progress = interpolate(
      frame,
      [TIMELINE.SELECTION_START + 25, TIMELINE.BUTTON_HIGHLIGHT],
      [0, 1],
      { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) }
    );
    cursorX = interpolate(progress, [0, 1], [cursorPositions.thumb4.x, cursorPositions.button.x]);
    cursorY = interpolate(progress, [0, 1], [cursorPositions.thumb4.y, cursorPositions.button.y]);
  } else if (frame <= TIMELINE.MODAL_CLOSE) {
    // At button - click animation visible for 8 frames
    cursorX = cursorPositions.button.x;
    cursorY = cursorPositions.button.y;
    isClicking = frame >= TIMELINE.BUTTON_CLICK && frame < TIMELINE.BUTTON_CLICK + 8;
  } else {
    // Stay at button position (cursor fades out here anyway)
    cursorX = cursorPositions.button.x;
    cursorY = cursorPositions.button.y;
  }

  // File visibility and state
  const fileOpacity = interpolate(
    frame,
    [TIMELINE.FILE_APPEAR, TIMELINE.FILE_APPEAR + 15, TIMELINE.MODAL_OPEN, TIMELINE.MODAL_OPEN + 10],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );
  const fileHighlighted = frame >= TIMELINE.CURSOR_REACH_FILE && frame < TIMELINE.MODAL_OPEN;

  // Modal state
  const modalOpen = frame >= TIMELINE.MODAL_OPEN && frame < TIMELINE.MODAL_CLOSE;

  // Selection state
  const selectionOrder = selectedPages;

  // Button state
  const buttonHighlighted = frame >= TIMELINE.BUTTON_HIGHLIGHT;
  const buttonClicked = frame >= TIMELINE.BUTTON_CLICK;

  // Section state
  const sectionVisible = frame >= TIMELINE.SECTION_APPEAR;

  // Cursor visibility - stays visible during click, fades after modal closes
  const cursorOpacity = interpolate(
    frame,
    [TIMELINE.CURSOR_APPEAR, TIMELINE.CURSOR_APPEAR + 10, TIMELINE.MODAL_CLOSE, TIMELINE.MODAL_CLOSE + 5],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );

  // Background stays consistently purple throughout - no fade
  const bgOpacity = 0.5;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#FFFFFF",
        fontFamily: "system-ui, -apple-system, sans-serif",
      }}
    >

      {/* File icon with label */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "45%",
          transform: "translate(-50%, -50%)",
          opacity: fileOpacity,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: "20px",
        }}
      >
        <FileIcon isHighlighted={fileHighlighted} />
        <div
          style={{
            fontSize: "24px",
            fontWeight: 500,
            color: "#6D28D9",
            letterSpacing: "0.5px",
          }}
        >
          Select a file
        </div>
      </div>

      {/* Modal with thumbnail grid */}
      <Modal isOpen={modalOpen} openFrame={TIMELINE.MODAL_OPEN} closeFrame={TIMELINE.MODAL_CLOSE}>
        <ThumbnailGrid
          selectedIndices={selectedPages}
          selectionStartFrame={TIMELINE.SELECTION_START}
          selectionOrder={selectionOrder}
        />
        <Button
          label="Add to Section"
          isHighlighted={buttonHighlighted}
          isClicked={buttonClicked}
          clickFrame={TIMELINE.BUTTON_CLICK}
        />
      </Modal>

      {/* New section with items */}
      <Section
        isVisible={sectionVisible}
        appearFrame={TIMELINE.SECTION_APPEAR}
        itemCount={selectedPages.length}
      />

      {/* Cursor */}
      <div style={{ opacity: cursorOpacity }}>
        <Cursor x={cursorX} y={cursorY} isClicking={isClicking} />
      </div>
    </AbsoluteFill>
  );
};
