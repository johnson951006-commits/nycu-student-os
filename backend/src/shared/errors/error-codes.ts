/**
 * Error-code registry (BIS §1.9) — the single source of truth mirroring the IRR §7
 * Error State Matrix. Every user-visible failure MUST use a registered code with
 * bilingual (zh-TW + en) messages. Adding a thrown code that is absent here, or a
 * code without both message keys, is a CI failure (registry-completeness test).
 *
 * User messages contain no codes, jargon, or blame (IRR §7 invariant).
 */
export interface ErrorCodeDef {
  readonly status: number;
  readonly messages: { readonly en: string; readonly 'zh-TW': string };
}

export const ERROR_CODES = {
  // --- IRR §7 Error State Matrix (the transcribed set) ---
  'E-PORTAL-DOWN': {
    status: 503,
    messages: {
      en: "NYCU Portal is unavailable — showing data from {t}. We'll retry automatically.",
      'zh-TW': '「NYCU Portal 目前無法連線——顯示 {t} 的資料，我們會自動重試。」',
    },
  },
  'E-DB-FAIL': {
    status: 500,
    messages: {
      en: 'Something went wrong on our side — your data is safe. Try again in a moment.',
      'zh-TW': '「我們這邊出了點問題——你的資料安全無虞，請稍後再試。」',
    },
  },
  'E-NET-TIMEOUT': {
    status: 504,
    messages: {
      en: 'Request timed out — check your connection.',
      'zh-TW': '「連線逾時——請確認網路狀態。」',
    },
  },
  'E-SYNC-FAIL': {
    status: 502,
    messages: {
      en: "We couldn't sync with Portal. Your data is current as of {t}.",
      'zh-TW': '「目前無法與 Portal 同步，資料更新至 {t}。」',
    },
  },
  'E-COOKIE-EXPIRED': {
    status: 401,
    messages: {
      en: 'Portal session expired — sign in to resume sync.',
      'zh-TW': '「Portal 登入已過期——請重新登入以繼續同步。」',
    },
  },
  'E-PERM-DENIED': {
    status: 403,
    messages: {
      en: "NYCU Portal didn't allow access to {category}. Other data still syncs.",
      'zh-TW': '「Portal 未開放存取{category}，其他資料仍會正常同步。」',
    },
  },
  'E-PARSE-DRIFT': {
    status: 503,
    messages: {
      en: 'NYCU changed their site — {category} sync is paused while we adapt (usually < a day). Your data is safe as of {t}.',
      'zh-TW': '「NYCU 更新了網站——{category} 同步暫停中，我們正在調整（通常一天內恢復）。你的資料保留至 {t}。」',
    },
  },
  'E-CAL-EXPAND': {
    status: 500,
    messages: {
      en: "Calendar couldn't refresh — showing your last saved schedule.",
      'zh-TW': '「行事曆暫時無法更新——顯示先前儲存的課表。」',
    },
  },
  'E-NOTIF-FAIL': {
    status: 500,
    messages: {
      en: "We couldn't deliver a notification. It's recorded in your Notification Center.",
      'zh-TW': '「通知傳送失敗，已記錄在通知中心。」',
    },
  },
  'E-UNEXPECTED': {
    status: 500,
    messages: {
      en: "Something unexpected happened. It's been reported — try again.",
      'zh-TW': '「發生非預期的錯誤，我們已收到回報——請再試一次。」',
    },
  },
  'E-PREF-SAVE': {
    status: 500,
    messages: {
      en: "Couldn't save that setting — try again.",
      'zh-TW': '「設定未能儲存——請再試一次。」',
    },
  },
  'E-SYNC-TOTAL': {
    status: 500,
    messages: {
      en: "We couldn't load your semester right now.",
      'zh-TW': '「目前無法載入你的學期資料。」',
    },
  },

  // --- API contract codes referenced by the backend spec (BIS §5 / §12) ---
  'E-COOKIE-INVALID': {
    status: 401,
    messages: {
      en: "Login didn't complete — please try again.",
      'zh-TW': '「登入未完成——請再試一次。」',
    },
  },
  SESSION_EXPIRED: {
    status: 401,
    messages: {
      en: 'Your Portal session expired. Sign in again to resume syncing.',
      'zh-TW': '「你的 Portal 登入已過期，請重新登入以繼續同步。」',
    },
  },
  TOKEN_EXPIRED: {
    status: 401,
    messages: {
      en: 'Your session token expired.',
      'zh-TW': '「登入權杖已過期。」',
    },
  },
  REFRESH_REUSED: {
    status: 401,
    messages: {
      en: 'For your security, please sign in again.',
      'zh-TW': '「基於安全考量，請重新登入。」',
    },
  },
  STALE_WRITE: {
    status: 409,
    messages: {
      en: 'This changed elsewhere — refresh and try again.',
      'zh-TW': '「此項目已在他處變更——請重新整理後再試。」',
    },
  },
  SYNC_COOLDOWN: {
    status: 429,
    messages: {
      en: 'Just synced — the next manual sync is available shortly.',
      'zh-TW': '「剛剛已同步——請稍候再手動同步。」',
    },
  },
  VALIDATION_FAILED: {
    status: 400,
    messages: {
      en: 'That request was invalid.',
      'zh-TW': '「請求格式不正確。」',
    },
  },
  AUTO_NOT_DELETABLE: {
    status: 400,
    messages: {
      en: "Synced items can't be deleted — hide it instead.",
      'zh-TW': '「同步的項目無法刪除——請改為隱藏。」',
    },
  },
} as const satisfies Record<string, ErrorCodeDef>;

export type ErrorCode = keyof typeof ERROR_CODES;

export function isErrorCode(value: string): value is ErrorCode {
  return Object.prototype.hasOwnProperty.call(ERROR_CODES, value);
}

/** The IRR §7 Error State Matrix codes — the mandatory subset (completeness test). */
export const IRR_MATRIX_CODES: readonly ErrorCode[] = [
  'E-PORTAL-DOWN',
  'E-DB-FAIL',
  'E-NET-TIMEOUT',
  'E-SYNC-FAIL',
  'E-COOKIE-EXPIRED',
  'E-PERM-DENIED',
  'E-PARSE-DRIFT',
  'E-CAL-EXPAND',
  'E-NOTIF-FAIL',
  'E-UNEXPECTED',
  'E-PREF-SAVE',
  'E-SYNC-TOTAL',
];
