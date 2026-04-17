CREATE TYPE "public"."actor_type" AS ENUM('llm', 'rule', 'human', 'pipeline');--> statement-breakpoint
CREATE TYPE "public"."admin_level" AS ENUM('dao', 'lu', 'fu', 'zhou', 'jun', 'xian', 'guan', 'other');--> statement-breakpoint
CREATE TYPE "public"."book_genre" AS ENUM('official_history', 'unofficial_history', 'poetry', 'philosophy', 'classic', 'geography', 'military', 'medical', 'encyclopedia', 'other');--> statement-breakpoint
CREATE TYPE "public"."conflict_type" AS ENUM('factual', 'chronological', 'interpretive', 'omission', 'attribution');--> statement-breakpoint
CREATE TYPE "public"."credibility_tier" AS ENUM('primary_official', 'primary_unofficial', 'secondary_compilation', 'tertiary_reference', 'folk');--> statement-breakpoint
CREATE TYPE "public"."diff_type" AS ENUM('char', 'word', 'phrase', 'structure');--> statement-breakpoint
CREATE TYPE "public"."event_type" AS ENUM('political', 'military', 'cultural', 'economic', 'social', 'religious', 'diplomatic', 'natural_disaster', 'other');--> statement-breakpoint
CREATE TYPE "public"."feedback_type" AS ENUM('factual_error', 'misleading', 'missing_evidence', 'suggestion', 'praise');--> statement-breakpoint
CREATE TYPE "public"."hypothesis_relation_type" AS ENUM('same_person', 'possibly_same', 'conflated', 'distinct_despite_similar_name');--> statement-breakpoint
CREATE TYPE "public"."inference_basis" AS ENUM('rule', 'context', 'llm', 'human');--> statement-breakpoint
CREATE TYPE "public"."intertextual_link_type" AS ENUM('quote', 'paraphrase', 'rebuttal', 'imitation', 'parody');--> statement-breakpoint
CREATE TYPE "public"."license" AS ENUM('CC0', 'CC-BY', 'public_domain', 'proprietary', 'unknown');--> statement-breakpoint
CREATE TYPE "public"."llm_call_status" AS ENUM('success', 'failure', 'retry', 'degraded');--> statement-breakpoint
CREATE TYPE "public"."mention_entity_type" AS ENUM('person', 'place', 'event', 'allusion', 'artifact', 'institution');--> statement-breakpoint
CREATE TYPE "public"."mention_type" AS ENUM('explicit', 'implicit', 'allusion', 'metaphor', 'pun', 'pseudonym', 'title_only', 'anonymous');--> statement-breakpoint
CREATE TYPE "public"."name_type" AS ENUM('primary', 'courtesy', 'art', 'studio', 'posthumous', 'temple', 'nickname', 'self_ref', 'alias');--> statement-breakpoint
CREATE TYPE "public"."pipeline_status" AS ENUM('pending', 'running', 'success', 'failure', 'skipped');--> statement-breakpoint
CREATE TYPE "public"."pipeline_step" AS ENUM('ingestion', 'preprocessing', 'ner', 'relations', 'events', 'disambiguation', 'geocoding', 'validation');--> statement-breakpoint
CREATE TYPE "public"."provenance_tier" AS ENUM('primary_text', 'scholarly_consensus', 'ai_inferred', 'crowdsourced', 'unverified');--> statement-breakpoint
CREATE TYPE "public"."reality_status" AS ENUM('historical', 'legendary', 'mythical', 'fictional', 'composite', 'uncertain');--> statement-breakpoint
CREATE TYPE "public"."relationship_type" AS ENUM('parent_child', 'spouse', 'sibling', 'teacher_student', 'lord_vassal', 'ally', 'enemy', 'colleague', 'other');--> statement-breakpoint
CREATE TYPE "public"."semantic_shift" AS ENUM('faithful', 'extended', 'ironic', 'subverted');--> statement-breakpoint
CREATE TYPE "public"."textual_note_type" AS ENUM('emendation', 'annotation', 'parallelism', 'commentary');--> statement-breakpoint
CREATE TYPE "public"."variant_char_type" AS ENUM('simplified', 'traditional', 'tongjia', 'yitizi', 'taboo');--> statement-breakpoint
CREATE TABLE "artifacts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"name" jsonb NOT NULL,
	"artifact_type" text,
	"description" jsonb,
	"dynasty" text,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "artifacts_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "entity_embeddings" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" uuid NOT NULL,
	"model_id" text NOT NULL,
	"model_version" text NOT NULL,
	"dimension" integer NOT NULL,
	"embedding" vector(1024),
	"content_hash" text NOT NULL,
	"is_active" boolean DEFAULT true,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "entity_revisions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" uuid NOT NULL,
	"revision_no" integer NOT NULL,
	"diff" jsonb NOT NULL,
	"actor_type" "actor_type" NOT NULL,
	"actor_id" text,
	"reason" text,
	"prompt_version" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "account_conflicts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"account_a_id" uuid NOT NULL,
	"account_b_id" uuid NOT NULL,
	"conflict_type" "conflict_type",
	"diff_summary" jsonb,
	"analysis" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "event_accounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"source_book_id" uuid,
	"narrative" jsonb NOT NULL,
	"participants" jsonb,
	"places" jsonb,
	"sequence" jsonb,
	"source_evidence_ids" jsonb DEFAULT '[]'::jsonb,
	"reliability_score" real DEFAULT 0.5,
	"is_canonical" boolean DEFAULT false,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "event_causality" (
	"cause_event_id" uuid NOT NULL,
	"effect_event_id" uuid NOT NULL,
	"confidence" real DEFAULT 0.5,
	"source_evidence_id" uuid,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"title" jsonb NOT NULL,
	"summary" jsonb,
	"significance" jsonb,
	"time_period_start" jsonb,
	"time_period_end" jsonb,
	"place_id" uuid,
	"event_type" "event_type",
	"importance_score" real,
	"canonical_account_id" uuid,
	"reality_status" reality_status DEFAULT 'historical' NOT NULL,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "events_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "feedback" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"anon_session_id" text,
	"entity_type" text,
	"entity_id" uuid,
	"evidence_id" uuid,
	"prompt_version" text,
	"model_version" text,
	"feedback_type" "feedback_type" NOT NULL,
	"note" text,
	"user_agent" text,
	"trace_id" text,
	"resolved" boolean DEFAULT false,
	"resolution_note" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "allusion_evolution" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"allusion_id" uuid NOT NULL,
	"era" text,
	"evolved_meaning" jsonb,
	"example_text" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "allusion_usages" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"allusion_id" uuid NOT NULL,
	"mention_id" uuid NOT NULL,
	"semantic_shift" "semantic_shift",
	"notes" jsonb
);
--> statement-breakpoint
CREATE TABLE "allusions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"name" jsonb NOT NULL,
	"origin_text" text,
	"original_meaning" jsonb,
	"modern_meaning" jsonb,
	"related_event_id" uuid,
	"related_person_id" uuid,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "allusions_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "books" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"title" jsonb NOT NULL,
	"author_person_id" uuid,
	"dynasty" text,
	"genre" "book_genre",
	"credibility_tier" "credibility_tier" NOT NULL,
	"license" "license" NOT NULL,
	"authoritative_version" text,
	"slug" text NOT NULL,
	"metadata" jsonb DEFAULT '{}'::jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "books_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "disambiguation_seeds" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"person_id" uuid,
	"dynasty_hint" text,
	"context_hint" text,
	"priority" integer DEFAULT 100
);
--> statement-breakpoint
CREATE TABLE "evidence_links" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"evidence_id" uuid NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" uuid NOT NULL,
	"role" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "extractions_history" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"pipeline_run_id" uuid,
	"paragraph_id" uuid NOT NULL,
	"step" "pipeline_step" NOT NULL,
	"prompt_version" text NOT NULL,
	"output" jsonb NOT NULL,
	"confidence" numeric(4, 3),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "identity_hypotheses" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"canonical_person_id" uuid NOT NULL,
	"hypothesis_person_id" uuid,
	"relation_type" "hypothesis_relation_type" NOT NULL,
	"scholarly_support" text,
	"evidence_ids" jsonb DEFAULT '[]'::jsonb,
	"accepted_by_default" boolean DEFAULT false,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "institution_changes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"institution_id" uuid NOT NULL,
	"year" integer,
	"change_description" jsonb,
	"source_text" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "institutions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"name" jsonb NOT NULL,
	"institution_type" text,
	"description" jsonb,
	"dynasty" text,
	"year_start" integer,
	"year_end" integer,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "institutions_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "intertextual_links" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"source_raw_text_id" uuid NOT NULL,
	"target_raw_text_id" uuid NOT NULL,
	"link_type" "intertextual_link_type" NOT NULL,
	"overlap_text" text,
	"confidence" real DEFAULT 0.5,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "llm_calls" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"prompt_id" text NOT NULL,
	"prompt_version" text NOT NULL,
	"prompt_hash" text NOT NULL,
	"input_hash" text NOT NULL,
	"model" text NOT NULL,
	"model_version" text,
	"input_tokens" integer,
	"output_tokens" integer,
	"cost_usd" numeric(10, 6),
	"latency_ms" integer,
	"response" jsonb,
	"traceguard_checkpoint_id" uuid,
	"status" "llm_call_status",
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mentions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"raw_text_id" uuid NOT NULL,
	"position_start" integer NOT NULL,
	"position_end" integer NOT NULL,
	"surface_text" text NOT NULL,
	"entity_type" "mention_entity_type",
	"entity_id" uuid,
	"mention_type" "mention_type" NOT NULL,
	"confidence" real DEFAULT 0.5 NOT NULL,
	"inference_basis" "inference_basis",
	"detector_version" text,
	"human_verified" boolean DEFAULT false,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "person_names" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"person_id" uuid NOT NULL,
	"name" text NOT NULL,
	"name_pinyin" text,
	"name_type" "name_type" NOT NULL,
	"start_year" integer,
	"end_year" integer,
	"is_primary" boolean DEFAULT false,
	"source_evidence_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "persons" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"name" jsonb NOT NULL,
	"dynasty" text,
	"reality_status" reality_status DEFAULT 'historical' NOT NULL,
	"birth_date" jsonb,
	"death_date" jsonb,
	"biography" jsonb,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "persons_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "pipeline_runs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"book_id" uuid,
	"paragraph_id" uuid,
	"step" "pipeline_step" NOT NULL,
	"status" "pipeline_status" NOT NULL,
	"prompt_version" text,
	"llm_call_id" uuid,
	"started_at" timestamp with time zone,
	"ended_at" timestamp with time zone,
	"error" text
);
--> statement-breakpoint
CREATE TABLE "place_hierarchies" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"place_id" uuid NOT NULL,
	"parent_place_id" uuid,
	"dynasty" text NOT NULL,
	"admin_level" "admin_level",
	"year_start" integer,
	"year_end" integer
);
--> statement-breakpoint
CREATE TABLE "place_names" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"place_id" uuid NOT NULL,
	"name" text NOT NULL,
	"dynasty" text,
	"year_start" integer,
	"year_end" integer,
	"geometry_variant" geometry(Geometry, 4326),
	"source_evidence_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "places" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"ancient_name" text,
	"modern_name" jsonb,
	"geometry" geometry(Geometry, 4326),
	"fuzziness" real DEFAULT 0,
	"modern_country" text DEFAULT 'CN',
	"reality_status" reality_status DEFAULT 'historical' NOT NULL,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "places_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "polities" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"name" jsonb NOT NULL,
	"dynasty" text,
	"year_start" integer,
	"year_end" integer,
	"capital_place_id" uuid,
	"metadata" jsonb DEFAULT '{}'::jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "polities_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "raw_texts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"source_id" text NOT NULL,
	"book_id" uuid,
	"volume" text,
	"chapter" text,
	"paragraph_no" integer,
	"raw_text" text NOT NULL,
	"text_original" text,
	"variant_of_id" uuid,
	"text_version" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "reign_eras" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"polity_id" uuid NOT NULL,
	"name" text NOT NULL,
	"year_start" integer NOT NULL,
	"year_end" integer,
	"emperor_person_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "relationships" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"person_a_id" uuid NOT NULL,
	"person_b_id" uuid NOT NULL,
	"relationship_type" "relationship_type" NOT NULL,
	"description" jsonb,
	"confidence" real DEFAULT 0.5,
	"source_text" text,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "role_appellations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"appellation" text NOT NULL,
	"resolve_rule" jsonb NOT NULL,
	CONSTRAINT "role_appellations_appellation_unique" UNIQUE("appellation")
);
--> statement-breakpoint
CREATE TABLE "source_evidences" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"raw_text_id" uuid,
	"position_start" integer,
	"position_end" integer,
	"quoted_text" text,
	"provenance_tier" "provenance_tier" DEFAULT 'primary_text' NOT NULL,
	"text_version" text,
	"book_id" uuid,
	"prompt_version" text,
	"llm_call_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "text_variants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"raw_text_a_id" uuid NOT NULL,
	"raw_text_b_id" uuid NOT NULL,
	"diff_position" integer,
	"diff_type" "diff_type",
	"diff_content" jsonb,
	"notes" text
);
--> statement-breakpoint
CREATE TABLE "textual_notes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"raw_text_id" uuid NOT NULL,
	"position_start" integer,
	"position_end" integer,
	"note_type" textual_note_type,
	"commentator" text,
	"content" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "variant_chars" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"char_canonical" text NOT NULL,
	"char_variant" text NOT NULL,
	"variant_type" "variant_char_type",
	"dynasty_scope" text,
	"notes" text
);
--> statement-breakpoint
ALTER TABLE "account_conflicts" ADD CONSTRAINT "account_conflicts_event_id_events_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_conflicts" ADD CONSTRAINT "account_conflicts_account_a_id_event_accounts_id_fk" FOREIGN KEY ("account_a_id") REFERENCES "public"."event_accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_conflicts" ADD CONSTRAINT "account_conflicts_account_b_id_event_accounts_id_fk" FOREIGN KEY ("account_b_id") REFERENCES "public"."event_accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_accounts" ADD CONSTRAINT "event_accounts_event_id_events_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_accounts" ADD CONSTRAINT "event_accounts_source_book_id_books_id_fk" FOREIGN KEY ("source_book_id") REFERENCES "public"."books"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_causality" ADD CONSTRAINT "event_causality_cause_event_id_events_id_fk" FOREIGN KEY ("cause_event_id") REFERENCES "public"."events"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_causality" ADD CONSTRAINT "event_causality_effect_event_id_events_id_fk" FOREIGN KEY ("effect_event_id") REFERENCES "public"."events"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_causality" ADD CONSTRAINT "event_causality_source_evidence_id_source_evidences_id_fk" FOREIGN KEY ("source_evidence_id") REFERENCES "public"."source_evidences"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "feedback" ADD CONSTRAINT "feedback_evidence_id_source_evidences_id_fk" FOREIGN KEY ("evidence_id") REFERENCES "public"."source_evidences"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "allusion_evolution" ADD CONSTRAINT "allusion_evolution_allusion_id_allusions_id_fk" FOREIGN KEY ("allusion_id") REFERENCES "public"."allusions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "allusion_usages" ADD CONSTRAINT "allusion_usages_allusion_id_allusions_id_fk" FOREIGN KEY ("allusion_id") REFERENCES "public"."allusions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "allusion_usages" ADD CONSTRAINT "allusion_usages_mention_id_mentions_id_fk" FOREIGN KEY ("mention_id") REFERENCES "public"."mentions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "allusions" ADD CONSTRAINT "allusions_related_event_id_events_id_fk" FOREIGN KEY ("related_event_id") REFERENCES "public"."events"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "allusions" ADD CONSTRAINT "allusions_related_person_id_persons_id_fk" FOREIGN KEY ("related_person_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "disambiguation_seeds" ADD CONSTRAINT "disambiguation_seeds_person_id_persons_id_fk" FOREIGN KEY ("person_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evidence_links" ADD CONSTRAINT "evidence_links_evidence_id_source_evidences_id_fk" FOREIGN KEY ("evidence_id") REFERENCES "public"."source_evidences"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "extractions_history" ADD CONSTRAINT "extractions_history_pipeline_run_id_pipeline_runs_id_fk" FOREIGN KEY ("pipeline_run_id") REFERENCES "public"."pipeline_runs"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "extractions_history" ADD CONSTRAINT "extractions_history_paragraph_id_raw_texts_id_fk" FOREIGN KEY ("paragraph_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "identity_hypotheses" ADD CONSTRAINT "identity_hypotheses_canonical_person_id_persons_id_fk" FOREIGN KEY ("canonical_person_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "identity_hypotheses" ADD CONSTRAINT "identity_hypotheses_hypothesis_person_id_persons_id_fk" FOREIGN KEY ("hypothesis_person_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "institution_changes" ADD CONSTRAINT "institution_changes_institution_id_institutions_id_fk" FOREIGN KEY ("institution_id") REFERENCES "public"."institutions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "intertextual_links" ADD CONSTRAINT "intertextual_links_source_raw_text_id_raw_texts_id_fk" FOREIGN KEY ("source_raw_text_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "intertextual_links" ADD CONSTRAINT "intertextual_links_target_raw_text_id_raw_texts_id_fk" FOREIGN KEY ("target_raw_text_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mentions" ADD CONSTRAINT "mentions_raw_text_id_raw_texts_id_fk" FOREIGN KEY ("raw_text_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "person_names" ADD CONSTRAINT "person_names_person_id_persons_id_fk" FOREIGN KEY ("person_id") REFERENCES "public"."persons"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "person_names" ADD CONSTRAINT "person_names_source_evidence_id_source_evidences_id_fk" FOREIGN KEY ("source_evidence_id") REFERENCES "public"."source_evidences"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pipeline_runs" ADD CONSTRAINT "pipeline_runs_book_id_books_id_fk" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pipeline_runs" ADD CONSTRAINT "pipeline_runs_paragraph_id_raw_texts_id_fk" FOREIGN KEY ("paragraph_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pipeline_runs" ADD CONSTRAINT "pipeline_runs_llm_call_id_llm_calls_id_fk" FOREIGN KEY ("llm_call_id") REFERENCES "public"."llm_calls"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "place_hierarchies" ADD CONSTRAINT "place_hierarchies_place_id_places_id_fk" FOREIGN KEY ("place_id") REFERENCES "public"."places"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "place_hierarchies" ADD CONSTRAINT "place_hierarchies_parent_place_id_places_id_fk" FOREIGN KEY ("parent_place_id") REFERENCES "public"."places"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "place_names" ADD CONSTRAINT "place_names_place_id_places_id_fk" FOREIGN KEY ("place_id") REFERENCES "public"."places"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "place_names" ADD CONSTRAINT "place_names_source_evidence_id_source_evidences_id_fk" FOREIGN KEY ("source_evidence_id") REFERENCES "public"."source_evidences"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "polities" ADD CONSTRAINT "polities_capital_place_id_places_id_fk" FOREIGN KEY ("capital_place_id") REFERENCES "public"."places"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "raw_texts" ADD CONSTRAINT "raw_texts_book_id_books_id_fk" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reign_eras" ADD CONSTRAINT "reign_eras_polity_id_polities_id_fk" FOREIGN KEY ("polity_id") REFERENCES "public"."polities"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reign_eras" ADD CONSTRAINT "reign_eras_emperor_person_id_persons_id_fk" FOREIGN KEY ("emperor_person_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "relationships" ADD CONSTRAINT "relationships_person_a_id_persons_id_fk" FOREIGN KEY ("person_a_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "relationships" ADD CONSTRAINT "relationships_person_b_id_persons_id_fk" FOREIGN KEY ("person_b_id") REFERENCES "public"."persons"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "source_evidences" ADD CONSTRAINT "source_evidences_raw_text_id_raw_texts_id_fk" FOREIGN KEY ("raw_text_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "source_evidences" ADD CONSTRAINT "source_evidences_book_id_books_id_fk" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "text_variants" ADD CONSTRAINT "text_variants_raw_text_a_id_raw_texts_id_fk" FOREIGN KEY ("raw_text_a_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "text_variants" ADD CONSTRAINT "text_variants_raw_text_b_id_raw_texts_id_fk" FOREIGN KEY ("raw_text_b_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "textual_notes" ADD CONSTRAINT "textual_notes_raw_text_id_raw_texts_id_fk" FOREIGN KEY ("raw_text_id") REFERENCES "public"."raw_texts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "idx_ee_entity_model" ON "entity_embeddings" USING btree ("entity_type","entity_id","model_id","model_version");--> statement-breakpoint
CREATE INDEX "idx_revisions_entity" ON "entity_revisions" USING btree ("entity_type","entity_id","revision_no");--> statement-breakpoint
CREATE INDEX "idx_accounts_event" ON "event_accounts" USING btree ("event_id");--> statement-breakpoint
CREATE INDEX "idx_feedback_entity" ON "feedback" USING btree ("entity_type","entity_id");--> statement-breakpoint
CREATE INDEX "idx_disamb_name" ON "disambiguation_seeds" USING btree ("name");--> statement-breakpoint
CREATE INDEX "idx_hypotheses_canonical" ON "identity_hypotheses" USING btree ("canonical_person_id");--> statement-breakpoint
CREATE INDEX "idx_llm_calls_cache" ON "llm_calls" USING btree ("prompt_hash","input_hash","model");--> statement-breakpoint
CREATE INDEX "idx_mentions_rawtext" ON "mentions" USING btree ("raw_text_id","position_start");--> statement-breakpoint
CREATE INDEX "idx_mentions_entity" ON "mentions" USING btree ("entity_type","entity_id");--> statement-breakpoint
CREATE INDEX "idx_mentions_type" ON "mentions" USING btree ("mention_type");--> statement-breakpoint
CREATE INDEX "idx_person_names_search" ON "person_names" USING gin ("name" gin_trgm_ops);--> statement-breakpoint
CREATE INDEX "idx_person_names_person" ON "person_names" USING btree ("person_id");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_pipeline_run_unique" ON "pipeline_runs" USING btree ("paragraph_id","step","prompt_version");--> statement-breakpoint
CREATE INDEX "idx_pipeline_status" ON "pipeline_runs" USING btree ("status","step");--> statement-breakpoint
CREATE INDEX "idx_place_hier_child" ON "place_hierarchies" USING btree ("place_id");--> statement-breakpoint
CREATE INDEX "idx_place_hier_parent" ON "place_hierarchies" USING btree ("parent_place_id");--> statement-breakpoint
CREATE INDEX "idx_variant_chars_pair" ON "variant_chars" USING btree ("char_canonical","char_variant");
