/// Optional self-declared role (DB §7 `users.role_preference` CHECK).
///
/// Nullable on [AuthUser]: the column is nullable, meaning "not declared".
enum RolePreference {
  student('student'),
  ta('ta');

  const RolePreference(this.wireValue);

  final String wireValue;
}
