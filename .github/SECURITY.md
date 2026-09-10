# Security Policy

## Our Commitment

phlex-hanami renders the HTML an application sends to a browser, so a flaw here can put one user's data in front of
another. We take security vulnerabilities seriously and will fix them promptly and in the open.

## What Constitutes a Security Vulnerability

A security vulnerability is an issue that could:

- Emit user input into a rendered page without escaping it
- Leak one request's exposures, view context or session into another request's render
- Hand a view data the action never exposed to it
- Weaken or bypass CSRF protection in a form or helper
- Expose sensitive information in error messages or logs
- Allow unexpected behavior through improper input handling

**Not security vulnerabilities:**

- General bugs that don't compromise security
- Feature requests or enhancements
- Performance issues
- Documentation errors

## Reporting a Vulnerability

If you discover a security issue, please bring it to our attention right away!

### Reporting Process

Please **DO NOT** file a public issue. Instead, report security vulnerabilities through
[GitHub's private vulnerability reporting feature][vulnerability-report].

Your report should include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact of the vulnerability
- Affected versions (if known)
- Suggested fix (if any)
- Your contact information for follow-up questions

### What to Expect

After you've submitted your report:

1. **Acknowledgment** - You'll receive confirmation within 24 hours
2. **Investigation** - We'll investigate and keep you updated on our findings
3. **Resolution** - Once we've determined the impact and developed a fix:

- We'll patch the vulnerability
- We'll coordinate disclosure timing with you
- We'll make an announcement to the community if warranted
- You'll be credited for the discovery (unless you prefer to remain anonymous)

### Response Timeline

- **24 hours** - Initial response acknowledging receipt
- **72 hours** - Preliminary assessment of impact and severity
- **7 days** - Detailed investigation results and remediation plan
- **30 days** - Target for patch release (may vary based on complexity)

## Disclosure Policy

We follow responsible disclosure practices:

1. **Confirm** the problem and determine affected versions
2. **Audit** code to find any similar problems
3. **Prepare** fixes for all supported versions
4. **Coordinate** with the reporter on disclosure timing
5. **Release** patches as soon as possible
6. **Publish** a security advisory with appropriate details

## Supported Versions

| Version | Support |
|:-------:|:-------:|
|  0.2.x  |   ✅    |
|  < 0.2  |   ❌    |

### Key

| Symbol | Meaning        |
|--------|----------------|
| ✅     | Supported      |
| ❌     | Not Supported  |
| 🧪     | Experimental   |
| 🚧     | In Development |

## Security Best Practices

When contributing to phlex-hanami, please follow these security guidelines:

- Never commit sensitive data (API keys, tokens, passwords) to the repository
- Leave Phlex's escaping on, and mark a string safe only when it truly is
- Keep the view's input filtered to the keywords its `initialize` declares
- Handle edge cases gracefully
- Keep dependencies up to date
- Use secure defaults in configuration

## Comments on this Policy

If you have suggestions on how this process could be improved, please submit a pull request or open an issue for
discussion.

## Contact

For urgent security matters that require immediate attention, you can also reach out to the maintainers directly
through GitHub.

[vulnerability-report]: https://github.com/aaronmallen/phlex-hanami/security/advisories/new
