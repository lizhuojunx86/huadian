import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import {
  HistoricalDateDisplay,
  formatYear,
  formatHistoricalDate,
} from "@/components/person/HistoricalDateDisplay";

describe("formatYear", () => {
  it("formats negative year as BC", () => {
    expect(formatYear(-256)).toBe("公元前 256 年");
  });

  it("formats positive year", () => {
    expect(formatYear(220)).toBe("220 年");
  });
});

describe("formatHistoricalDate", () => {
  it("prioritizes originalText", () => {
    expect(
      formatHistoricalDate({
        yearMin: -256,
        yearMax: null,
        precision: "year",
        originalText: "秦昭襄王五十一年",
        reignEra: null,
        reignYear: null,
      }),
    ).toBe("秦昭襄王五十一年");
  });

  it("formats yearMin~yearMax range", () => {
    expect(
      formatHistoricalDate({
        yearMin: -256,
        yearMax: -195,
        precision: "year_range",
        originalText: null,
        reignEra: null,
        reignYear: null,
      }),
    ).toBe("公元前 256 年 ~ 公元前 195 年");
  });

  it("formats single yearMin", () => {
    expect(
      formatHistoricalDate({
        yearMin: -195,
        yearMax: null,
        precision: "year",
        originalText: null,
        reignEra: null,
        reignYear: null,
      }),
    ).toBe("公元前 195 年");
  });

  it("returns 不详 when no data", () => {
    expect(
      formatHistoricalDate({
        yearMin: null,
        yearMax: null,
        precision: "unknown",
        originalText: null,
        reignEra: null,
        reignYear: null,
      }),
    ).toBe("不详");
  });
});

describe("HistoricalDateDisplay", () => {
  it("renders label and formatted date", () => {
    render(
      <HistoricalDateDisplay
        label="生"
        date={{
          yearMin: -256,
          yearMax: null,
          precision: "year",
          originalText: "秦昭襄王五十一年",
          reignEra: "昭襄王",
          reignYear: 51,
        }}
      />,
    );
    expect(screen.getByText("生")).toBeInTheDocument();
    expect(screen.getByText("秦昭襄王五十一年")).toBeInTheDocument();
  });
});
