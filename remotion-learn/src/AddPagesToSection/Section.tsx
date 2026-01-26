import React from "react";
import { useCurrentFrame, interpolate, Easing } from "remotion";

interface SectionProps {
  isVisible: boolean;
  appearFrame: number;
  itemCount: number;
}

export const Section: React.FC<SectionProps> = ({
  isVisible,
  appearFrame,
  itemCount,
}) => {
  const frame = useCurrentFrame();

  // Fast 3-frame fade in to match first portion
  const containerOpacity = interpolate(
    frame,
    [appearFrame, appearFrame + 3],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.ease) }
  );

  // Item appears 3 frames after container, also 3-frame transition
  const itemOpacity = interpolate(
    frame,
    [appearFrame + 3, appearFrame + 6],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.ease) }
  );
  const itemTranslateY = interpolate(
    frame,
    [appearFrame + 3, appearFrame + 6],
    [-8, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.ease) }
  );
  const itemScale = interpolate(
    frame,
    [appearFrame + 3, appearFrame + 6],
    [0.97, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.ease) }
  );

  if (!isVisible || frame < appearFrame) return null;

  return (
    <div
      style={{
        position: "absolute",
        top: "50%",
        left: "50%",
        transform: "translateX(-50%) translateY(-50%)",
        opacity: containerOpacity,
      }}
    >
      {/* Stacked section container */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "0",
          width: "280px",
        }}
      >
        {/* Section header */}
        <div
          style={{
            backgroundColor: "#EDE9FE",
            padding: "14px 20px",
            borderRadius: "12px 12px 0 0",
            borderBottom: "1px solid #DDD6FE",
          }}
        >
          <div
            style={{
              fontSize: "13px",
              fontWeight: 600,
              color: "#6D28D9",
              fontFamily: "system-ui, sans-serif",
              textTransform: "uppercase",
              letterSpacing: "0.5px",
            }}
          >
            Exhibit Package Section
          </div>
        </div>

        {/* New file item - inserted below */}
        <div
          style={{
            backgroundColor: "#FAF5FF",
            padding: "16px 20px",
            borderRadius: "0 0 12px 12px",
            border: "1px solid #EDE9FE",
            borderTop: "none",
            opacity: itemOpacity,
            transform: `translateY(${itemTranslateY}px) scale(${itemScale})`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "14px",
            }}
          >
            {/* File icon */}
            <div
              style={{
                width: "44px",
                height: "56px",
                backgroundColor: "#DDD6FE",
                borderRadius: "6px",
                display: "flex",
                flexDirection: "column",
                padding: "8px",
                gap: "4px",
                flexShrink: 0,
              }}
            >
              <div style={{ width: "60%", height: "4px", backgroundColor: "#A78BFA", borderRadius: "2px" }} />
              <div style={{ width: "80%", height: "4px", backgroundColor: "#A78BFA", borderRadius: "2px" }} />
              <div style={{ width: "50%", height: "4px", backgroundColor: "#A78BFA", borderRadius: "2px" }} />
            </div>

            {/* File info */}
            <div style={{ flex: 1 }}>
              <div
                style={{
                  fontSize: "14px",
                  fontWeight: 500,
                  color: "#4C1D95",
                  fontFamily: "system-ui, sans-serif",
                  marginBottom: "4px",
                }}
              >
                Selected pages
              </div>
              <div
                style={{
                  fontSize: "12px",
                  color: "#7C3AED",
                  fontFamily: "system-ui, sans-serif",
                }}
              >
                {itemCount} {itemCount === 1 ? "page" : "pages"}
              </div>
            </div>

            {/* Stacked pages indicator */}
            <div
              style={{
                position: "relative",
                width: "32px",
                height: "40px",
              }}
            >
              {Array.from({ length: Math.min(itemCount, 3) }).map((_, i) => (
                <div
                  key={i}
                  style={{
                    position: "absolute",
                    width: "24px",
                    height: "30px",
                    backgroundColor: i === 0 ? "#C4B5FD" : i === 1 ? "#DDD6FE" : "#EDE9FE",
                    borderRadius: "4px",
                    border: "1px solid #A78BFA",
                    top: i * 4,
                    left: i * 3,
                    zIndex: 3 - i,
                  }}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
