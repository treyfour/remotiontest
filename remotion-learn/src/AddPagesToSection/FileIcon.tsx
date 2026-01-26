import React from "react";

interface FileIconProps {
  isHighlighted?: boolean;
  scale?: number;
}

export const FileIcon: React.FC<FileIconProps> = ({
  isHighlighted = false,
  scale = 1,
}) => {
  return (
    <div
      style={{
        transform: `scale(${scale})`,
        transition: "transform 0.2s ease-out",
      }}
    >
      <svg width="80" height="100" viewBox="0 0 80 100">
        <defs>
          <linearGradient id="fileGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor={isHighlighted ? "#DDD6FE" : "#F3F4F6"} />
            <stop offset="100%" stopColor={isHighlighted ? "#C4B5FD" : "#E5E7EB"} />
          </linearGradient>
          <filter id="fileShadow" x="-20%" y="-20%" width="140%" height="140%">
            <feDropShadow
              dx="0"
              dy="4"
              stdDeviation="8"
              floodColor={isHighlighted ? "#8B5CF6" : "#000000"}
              floodOpacity={isHighlighted ? 0.3 : 0.1}
            />
          </filter>
        </defs>
        {/* File body */}
        <path
          d="M 8 0 L 56 0 L 72 16 L 72 92 C 72 96.4 68.4 100 64 100 L 8 100 C 3.6 100 0 96.4 0 92 L 0 8 C 0 3.6 3.6 0 8 0 Z"
          fill="url(#fileGradient)"
          filter="url(#fileShadow)"
        />
        {/* Folded corner */}
        <path
          d="M 56 0 L 56 16 L 72 16 Z"
          fill={isHighlighted ? "#A78BFA" : "#D1D5DB"}
        />
        {/* Content lines */}
        <rect x="12" y="32" width="48" height="4" rx="2" fill={isHighlighted ? "#A78BFA" : "#D1D5DB"} />
        <rect x="12" y="44" width="40" height="4" rx="2" fill={isHighlighted ? "#A78BFA" : "#D1D5DB"} />
        <rect x="12" y="56" width="44" height="4" rx="2" fill={isHighlighted ? "#A78BFA" : "#D1D5DB"} />
        <rect x="12" y="68" width="32" height="4" rx="2" fill={isHighlighted ? "#A78BFA" : "#D1D5DB"} />
      </svg>
    </div>
  );
};
