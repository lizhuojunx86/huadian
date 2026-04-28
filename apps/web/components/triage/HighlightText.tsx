import { Fragment } from "react";

interface HighlightTextProps {
  text: string;
  needle: string;
  className?: string;
}

/**
 * Render text with every literal occurrence of `needle` wrapped in a
 * <mark> with bg-yellow-200. Multi-occurrence supported via split. When
 * needle is empty or not present, the original text is rendered verbatim.
 */
export function HighlightText({ text, needle, className }: HighlightTextProps) {
  if (!needle) return <span className={className}>{text}</span>;

  const parts = text.split(needle);
  if (parts.length === 1) return <span className={className}>{text}</span>;

  return (
    <span className={className}>
      {parts.map((part, i) => (
        <Fragment key={i}>
          {part}
          {i < parts.length - 1 ? (
            <mark className="rounded-sm bg-yellow-200 px-0.5">{needle}</mark>
          ) : null}
        </Fragment>
      ))}
    </span>
  );
}
