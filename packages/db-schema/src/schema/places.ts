/**
 * D layer — Geography & Time tables.
 * places / place_names / place_hierarchies / polities / reign_eras
 *
 * PostGIS GEOMETRY handled via customType (PoC required per subtask 5).
 */
import {
  pgTable,
  uuid,
  text,
  integer,
  jsonb,
  timestamp,
  real,
  index,
  customType,
} from "drizzle-orm/pg-core";
import {
  realityStatusEnum,
  provenanceTierEnum,
  adminLevelEnum,
} from "./enums";
import { sourceEvidences } from "./sources";
import { persons } from "./persons";

// JSONB type hints
interface MultiLangText {
  "zh-Hans": string;
  "zh-Hant"?: string;
  en?: string;
}

// ============================================================
// PostGIS GEOMETRY custom type for Drizzle
// Stores GeoJSON-compatible geometry (Point/Line/Polygon), SRID 4326
// ============================================================
const geometry = customType<{
  data: Record<string, unknown>;
  driverData: string;
}>({
  dataType() {
    return "geometry(Geometry, 4326)";
  },
  toDriver(value: Record<string, unknown>): string {
    return JSON.stringify(value);
  },
  fromDriver(value: string): Record<string, unknown> {
    // PostGIS returns hex-encoded WKB; for JSON, use ST_AsGeoJSON in queries
    if (typeof value === "string") {
      try {
        return JSON.parse(value) as Record<string, unknown>;
      } catch {
        return { raw: value };
      }
    }
    return value as Record<string, unknown>;
  },
});

// ============================================================
// D1: places — Geographic entities
// ============================================================
export const places = pgTable("places", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(),
  ancientName: text("ancient_name"),
  modernName: jsonb("modern_name").$type<MultiLangText>(),
  geometry: geometry("geometry"),
  fuzziness: real("fuzziness").default(0),
  modernCountry: text("modern_country").default("CN"),
  realityStatus: realityStatusEnum("reality_status").notNull().default("historical"),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// D2: place_names — Historical names per dynasty
// ============================================================
export const placeNames = pgTable("place_names", {
  id: uuid("id").defaultRandom().primaryKey(),
  placeId: uuid("place_id").references(() => places.id).notNull(),
  name: text("name").notNull(), // Historical original — TEXT
  dynasty: text("dynasty"),
  yearStart: integer("year_start"),
  yearEnd: integer("year_end"),
  geometryVariant: geometry("geometry_variant"),
  sourceEvidenceId: uuid("source_evidence_id").references(() => sourceEvidences.id),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

// ============================================================
// D3: place_hierarchies — Administrative hierarchy per dynasty
// ============================================================
export const placeHierarchies = pgTable("place_hierarchies", {
  id: uuid("id").defaultRandom().primaryKey(),
  placeId: uuid("place_id").references(() => places.id).notNull(),
  parentPlaceId: uuid("parent_place_id").references(() => places.id),
  dynasty: text("dynasty").notNull(),
  adminLevel: adminLevelEnum("admin_level"),
  yearStart: integer("year_start"),
  yearEnd: integer("year_end"),
}, (table) => [
  index("idx_place_hier_child").on(table.placeId),
  index("idx_place_hier_parent").on(table.parentPlaceId),
]);

// ============================================================
// D4: polities — Dynasties / political entities (R-1: +slug/deleted_at/timestamps)
// ============================================================
export const polities = pgTable("polities", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(), // R-1
  name: jsonb("name").$type<MultiLangText>().notNull(),
  dynasty: text("dynasty"),
  yearStart: integer("year_start"),
  yearEnd: integer("year_end"),
  capitalPlaceId: uuid("capital_place_id").references(() => places.id),
  metadata: jsonb("metadata").default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(), // R-1
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(), // R-1
  deletedAt: timestamp("deleted_at", { withTimezone: true }), // R-1
});

// ============================================================
// D5: reign_eras — Era names (R-1: +deleted_at/timestamps; Q-3: name stays TEXT)
// ============================================================
export const reignEras = pgTable("reign_eras", {
  id: uuid("id").defaultRandom().primaryKey(),
  polityId: uuid("polity_id").references(() => polities.id).notNull(),
  name: text("name").notNull(), // Historical proper noun — TEXT, not JSONB (Q-3)
  yearStart: integer("year_start").notNull(),
  yearEnd: integer("year_end"),
  emperorPersonId: uuid("emperor_person_id").references(() => persons.id),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(), // R-1
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(), // R-1
  deletedAt: timestamp("deleted_at", { withTimezone: true }), // R-1
});
