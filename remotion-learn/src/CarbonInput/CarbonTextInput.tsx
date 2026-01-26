import React from "react";

// Carbon Design System v11 Text Input - Pixel Perfect Recreation
// Based on: https://carbondesignsystem.com/components/text-input/style/

interface CarbonTextInputProps {
  label: string;
  placeholder: string;
  helperText?: string;
  value: string;
  isFocused: boolean;
  showCursor?: boolean;
}

const styles = {
  container: {
    display: "flex",
    alignItems: "center",
    gap: "16px",
    fontFamily: "'IBM Plex Sans', sans-serif",
  },
  label: {
    fontSize: "14px",
    fontWeight: 400,
    color: "#525252",
    letterSpacing: "0.16px",
    minWidth: "40px",
  },
  inputWrapper: {
    position: "relative" as const,
    flex: 1,
    maxWidth: "600px",
  },
  input: {
    width: "100%",
    height: "48px",
    backgroundColor: "#f4f4f4",
    border: "none",
    borderBottom: "1px solid #8d8d8d",
    padding: "0 16px",
    fontSize: "14px",
    fontWeight: 400,
    color: "#161616",
    letterSpacing: "0.16px",
    fontFamily: "'IBM Plex Sans', sans-serif",
    outline: "none",
    boxSizing: "border-box" as const,
  },
  inputFocused: {
    outline: "2px solid #0f62fe",
    outlineOffset: "-2px",
  },
  placeholder: {
    position: "absolute" as const,
    left: "16px",
    top: "50%",
    transform: "translateY(-50%)",
    fontSize: "14px",
    fontWeight: 400,
    color: "#a8a8a8",
    letterSpacing: "0.16px",
    pointerEvents: "none" as const,
    fontFamily: "'IBM Plex Sans', sans-serif",
  },
  valueText: {
    position: "absolute" as const,
    left: "16px",
    top: "50%",
    transform: "translateY(-50%)",
    fontSize: "14px",
    fontWeight: 400,
    color: "#161616",
    letterSpacing: "0.16px",
    pointerEvents: "none" as const,
    fontFamily: "'IBM Plex Sans', sans-serif",
    display: "flex",
    alignItems: "center",
  },
  cursor: {
    display: "inline-block",
    width: "1px",
    height: "18px",
    backgroundColor: "#161616",
    marginLeft: "1px",
  },
  helperText: {
    fontSize: "12px",
    fontWeight: 400,
    color: "#6f6f6f",
    letterSpacing: "0.32px",
    minWidth: "140px",
  },
};

export const CarbonTextInput: React.FC<CarbonTextInputProps> = ({
  label,
  placeholder,
  helperText,
  value,
  isFocused,
  showCursor = false,
}) => {
  const showPlaceholder = value.length === 0;

  return (
    <div style={styles.container}>
      <span style={styles.label}>{label}</span>
      <div style={styles.inputWrapper}>
        <div
          style={{
            ...styles.input,
            ...(isFocused ? styles.inputFocused : {}),
          }}
        />
        {showPlaceholder ? (
          <span style={styles.placeholder}>{placeholder}</span>
        ) : (
          <span style={styles.valueText}>
            {value}
            {showCursor && <span style={styles.cursor} />}
          </span>
        )}
      </div>
      {helperText && <span style={styles.helperText}>{helperText}</span>}
    </div>
  );
};
