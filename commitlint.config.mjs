// Commit message rules: see CONTRIBUTING.md, section 3.
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'header-max-length': [2, 'always', 100],
    'scope-enum': [
      1,
      'always',
      ['api', 'web', 'db', 'auth', 'routing', 'sla', 'realtime', 'docker', 'jenkins', 'k8s', 'monitoring'],
    ],
  },
};
