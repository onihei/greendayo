// Canonical nickname module for susipero.com.
// 各ゲーム (nasbi / kaeru / sumomo) はこのファイルをコピーして使用する。
// 仕様変更時は greendayo の本ファイルを最初に更新すること。
// 仕様: openspec/changes/.../specs/shared-nickname/spec.md

export const STORAGE_KEY_NICKNAME = 'susipero:nickname'

const LEGACY_KEYS = [
  'nasbi:userName',
  'kaeru:userName',
  'sumomo:userName',
] as const

export type ValidateResult =
  | { ok: true; value: string }
  | { ok: false; reason: string }

function getStorage(): Storage | null {
  if (typeof window === 'undefined') return null
  try {
    return window.localStorage
  } catch {
    return null
  }
}

export function validateNickname(input: unknown): ValidateResult {
  if (typeof input !== 'string') {
    return { ok: false, reason: 'ニックネームを入力してください' }
  }
  if (/[\n\r\t]/.test(input)) {
    return { ok: false, reason: '改行やタブは使えません' }
  }
  const trimmed = input.trim()
  if (trimmed.length === 0) {
    return { ok: false, reason: 'ニックネームを入力してください' }
  }
  if (trimmed.length > 20) {
    return { ok: false, reason: '20 文字以内で入力してください' }
  }
  return { ok: true, value: trimmed }
}

function migrateLegacyNickname(): string | null {
  const storage = getStorage()
  if (!storage) return null
  for (const key of LEGACY_KEYS) {
    const value = storage.getItem(key)
    if (value !== null && value !== '') {
      storage.setItem(STORAGE_KEY_NICKNAME, value)
      return value
    }
  }
  return null
}

export function getNickname(): string | null {
  const storage = getStorage()
  if (!storage) return null
  const current = storage.getItem(STORAGE_KEY_NICKNAME)
  if (current !== null && current !== '') return current
  return migrateLegacyNickname()
}

export function setNickname(name: string): void {
  const storage = getStorage()
  if (!storage) return
  storage.setItem(STORAGE_KEY_NICKNAME, name)
}

export function clearNickname(): void {
  const storage = getStorage()
  if (!storage) return
  storage.removeItem(STORAGE_KEY_NICKNAME)
}
