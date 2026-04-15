/**
 * Analytics event dictionary — Phase 0 stub.
 * Real events will be defined by the data analyst role.
 */

export interface AnalyticsEvent {
  name: string;
  properties: Record<string, unknown>;
}

export const EVENTS = {
  PAGE_VIEW: "page_view",
  SEARCH: "search",
  PERSON_CARD_VIEW: "person_card_view",
  ENTITY_LINK_CLICK: "entity_link_click",
} as const;

export type EventName = (typeof EVENTS)[keyof typeof EVENTS];
