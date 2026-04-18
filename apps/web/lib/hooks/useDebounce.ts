import { useEffect, useState } from "react";

/**
 * Debounce a value by `delay` ms. Returns the debounced value.
 * The returned value only updates after the caller stops changing
 * `value` for at least `delay` milliseconds.
 */
export function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debounced;
}
