export function deriveDisplayNameFromEmail(email: string): string {
  const localPart = email.trim().split('@')[0] ?? '';
  const normalized = localPart
    .replaceAll(/([a-z0-9])([A-Z])/g, '$1 $2')
    .replaceAll(/[._-]+/g, ' ')
    .replaceAll(/\s+/g, ' ')
    .trim();

  if (!normalized) {
    return localPart;
  }

  return normalized
    .split(' ')
    .filter(Boolean)
    .map((segment) => {
      const lower = segment.toLowerCase();
      return lower.charAt(0).toUpperCase() + lower.slice(1);
    })
    .join(' ');
}