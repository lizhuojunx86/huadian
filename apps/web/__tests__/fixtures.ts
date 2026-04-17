import type { PersonQuery } from "@/lib/graphql/generated/graphql";

type Person = NonNullable<PersonQuery["person"]>;

export const mockPerson: Person = {
  __typename: "Person",
  id: "550e8400-e29b-41d4-a716-446655440000",
  slug: "liu-bang",
  name: {
    __typename: "MultiLangText",
    zhHans: "刘邦",
    zhHant: "劉邦",
    en: "Liu Bang",
  },
  dynasty: "西汉",
  realityStatus: "historical",
  provenanceTier: "primary_text",
  birthDate: {
    __typename: "HistoricalDate",
    yearMin: -256,
    yearMax: null,
    precision: "year",
    originalText: "秦昭襄王五十一年",
    reignEra: "昭襄王",
    reignYear: 51,
  },
  deathDate: {
    __typename: "HistoricalDate",
    yearMin: -195,
    yearMax: null,
    precision: "year",
    originalText: null,
    reignEra: null,
    reignYear: null,
  },
  biography: {
    __typename: "MultiLangText",
    zhHans: "汉太祖高皇帝刘邦，沛郡丰邑中阳里人，汉朝开国皇帝。",
    en: "Liu Bang was the founder and first emperor of the Han dynasty.",
  },
  names: [
    {
      __typename: "PersonName",
      id: "name-1",
      name: "刘季",
      namePinyin: "Liú Jì",
      nameType: "primary",
      isPrimary: true,
      startYear: null,
      endYear: null,
    },
    {
      __typename: "PersonName",
      id: "name-2",
      name: "汉高祖",
      namePinyin: "Hàn Gāozǔ",
      nameType: "temple",
      isPrimary: false,
      startYear: -202,
      endYear: -195,
    },
  ],
  identityHypotheses: [
    {
      __typename: "IdentityHypothesis",
      id: "hyp-1",
      relationType: "same_person",
      scholarlySupport: "《史记·高祖本纪》明确记载",
      acceptedByDefault: true,
      notes: "刘邦与汉高祖为同一人，无争议。",
    },
  ],
};

export const mockPersonMinimal: Person = {
  __typename: "Person",
  id: "660e8400-e29b-41d4-a716-446655440001",
  slug: "unknown-person",
  name: {
    __typename: "MultiLangText",
    zhHans: "佚名",
    zhHant: null,
    en: null,
  },
  dynasty: null,
  realityStatus: "uncertain",
  provenanceTier: "unverified",
  birthDate: null,
  deathDate: null,
  biography: null,
  names: [],
  identityHypotheses: [],
};
