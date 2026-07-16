// Conventional Commits configuration (BEP §1.8).
// Types and scopes mirror the label taxonomy (BEP §1.4) so commit history,
// changelog, and triage share one vocabulary.
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'chore', 'docs', 'test', 'infra'],
    ],
    'scope-enum': [
      2,
      'always',
      [
        'backend',
        'flutter',
        'sync',
        'notif',
        'auth',
        'calendar',
        'db',
        'ci',
        'design',
        'contracts',
        'repo',
      ],
    ],
    'scope-empty': [1, 'never'],
    'subject-case': [2, 'never', ['upper-case', 'pascal-case', 'start-case']],
    'body-max-line-length': [0, 'always'],
  },
};
