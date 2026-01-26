import React from "react";
import { spring, useCurrentFrame, useVideoConfig } from "remotion";

interface ThumbnailGridProps {
  selectedIndices: number[];
  selectionStartFrame: number;
  selectionOrder: number[]; // Order in which thumbnails are selected
}

const Thumbnail: React.FC<{
  index: number;
  isSelected: boolean;
  selectionFrame: number;
}> = ({ index, isSelected, selectionFrame }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const selectionProgress = spring({
    frame: isSelected ? frame - selectionFrame : 0,
    fps,
    config: { damping: 15, stiffness: 200 },
  });

  // Different shades of purple for variety
  const shades = [
    { bg: "#F5F3FF", line: "#DDD6FE" },
    { bg: "#EDE9FE", line: "#C4B5FD" },
    { bg: "#DDD6FE", line: "#A78BFA" },
  ];
  const shade = shades[index % shades.length];

  return (
    <div
      style={{
        width: "120px",
        height: "160px",
        backgroundColor: shade.bg,
        borderRadius: "12px",
        padding: "12px",
        position: "relative",
        border: isSelected
          ? `3px solid #8B5CF6`
          : "3px solid transparent",
        boxSizing: "border-box",
        transform: `scale(${1 + selectionProgress * 0.05})`,
        boxShadow: isSelected
          ? "0 8px 24px rgba(139, 92, 246, 0.3)"
          : "0 2px 8px rgba(0, 0, 0, 0.05)",
        transition: "border-color 0.15s ease",
      }}
    >
      {/* Mini content lines */}
      <div
        style={{
          width: "70%",
          height: "8px",
          backgroundColor: shade.line,
          borderRadius: "4px",
          marginBottom: "8px",
        }}
      />
      <div
        style={{
          width: "90%",
          height: "8px",
          backgroundColor: shade.line,
          borderRadius: "4px",
          marginBottom: "8px",
        }}
      />
      <div
        style={{
          width: "60%",
          height: "8px",
          backgroundColor: shade.line,
          borderRadius: "4px",
          marginBottom: "8px",
        }}
      />
      <div
        style={{
          width: "80%",
          height: "8px",
          backgroundColor: shade.line,
          borderRadius: "4px",
        }}
      />

      {/* Selection checkmark */}
      {isSelected && (
        <div
          style={{
            position: "absolute",
            top: "-8px",
            right: "-8px",
            width: "28px",
            height: "28px",
            backgroundColor: "#8B5CF6",
            borderRadius: "50%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            transform: `scale(${selectionProgress})`,
            boxShadow: "0 2px 8px rgba(139, 92, 246, 0.4)",
          }}
        >
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
            <path
              d="M2 7L5.5 10.5L12 4"
              stroke="white"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </div>
      )}
    </div>
  );
};

export const ThumbnailGrid: React.FC<ThumbnailGridProps> = ({
  selectedIndices,
  selectionStartFrame,
  selectionOrder,
}) => {
  const frame = useCurrentFrame();

  // Calculate when each thumbnail was selected
  const getSelectionFrame = (index: number) => {
    const orderIndex = selectionOrder.indexOf(index);
    if (orderIndex === -1) return 0;
    return selectionStartFrame + orderIndex * 15; // 15 frames between each selection
  };

  return (
    <div>
      {/* Modal header */}
      <div
        style={{
          marginBottom: "24px",
          fontSize: "18px",
          fontWeight: 600,
          color: "#4C1D95",
          fontFamily: "system-ui, sans-serif",
        }}
      >
        Select pages
      </div>

      {/* Grid */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(3, 1fr)",
          gap: "16px",
        }}
      >
        {[0, 1, 2, 3, 4, 5, 6, 7, 8].map((index) => {
          const isSelected = selectedIndices.includes(index);
          const selectionFrame = getSelectionFrame(index);
          const isActiveSelection = isSelected && frame >= selectionFrame;

          return (
            <Thumbnail
              key={index}
              index={index}
              isSelected={isActiveSelection}
              selectionFrame={selectionFrame}
            />
          );
        })}
      </div>
    </div>
  );
};
