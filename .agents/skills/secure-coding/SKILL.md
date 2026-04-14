---
name: secure-coding
description: Apply secure coding practices to prevent common security vulnerabilities including information leakage, injection attacks, authentication flaws, and insecure error handling. Use when writing authentication code, handling errors, processing user input, or when security review is needed.
---

# Secure Coding Practices

## Overview

Apply OWASP-aligned secure coding practices to prevent common vulnerabilities. Focus on:
- Information leakage prevention
- Secure authentication and session management
- Input validation and sanitization
- Secure error handling
- Output encoding

## Core Principles

### 1. Information Leakage Prevention

**Never expose internal implementation details to users.**

**Anti-pattern (Information Leakage):**
```dart
// BAD: Exposes Firebase implementation details
catch (e) {
  setState(() => _error = e.toString()); // Shows "[firebase_auth/email-already-in-use]..."
}
```

**Secure Pattern:**
```dart
// GOOD: Maps errors to user-friendly messages
String _getErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email address is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password. Please try again.'; // Intentionally vague
      default:
        return 'Unable to complete request. Please try again later.';
    }
  }
  return 'An unexpected error occurred. Please try again.';
}
```

**Key Rules:**
- Never expose framework/library names in error messages
- Never expose stack traces to end users
- Use generic messages for authentication failures (prevent user enumeration)
- Log detailed errors server-side only

### 2. Secure Authentication

**Password Requirements:**
- Minimum 8 characters (OWASP recommends 12+)
- Support passphrases (longer is better than complex)
- Never store passwords in plain text
- Use secure hashing (bcrypt, Argon2, PBKDF2)

**Authentication Error Handling:**
- Use identical error messages for "user not found" and "wrong password"
- Implement rate limiting to prevent brute force
- Use account lockout after failed attempts (with care)
- Implement secure password reset flows

**Session Management:**
- Use secure, httpOnly cookies
- Implement session timeout
- Regenerate session ID on privilege change
- Invalidate sessions on logout

### 3. Input Validation

**Validate All Input:**
```dart
// Server-side validation is mandatory
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  // Use strict regex, not just basic pattern
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}
```

**Validation Principles:**
- Validate on server-side (client-side is for UX only)
- Whitelist allowed characters/patterns
- Reject invalid input (don't sanitize)
- Validate length, type, format, and range

### 4. Output Encoding

**Prevent Injection Attacks:**
- Encode all output based on context (HTML, JavaScript, URL, CSS)
- Use parameterized queries for database access
- Never concatenate user input into SQL/NoSQL queries
- Escape special characters in dynamic content

**Example (Dart/Flutter web):**
```dart
import 'package:html_unescape/html_unescape.dart';

// Encode for HTML context
String encodeForHtml(String input) {
  return const HtmlEscape().convert(input);
}
```

### 5. Secure Error Handling

**Error Handling Checklist:**
- [ ] Catch specific exceptions, not generic `Exception`
- [ ] Log detailed errors with context (server-side)
- [ ] Return generic messages to users
- [ ] Don't expose file paths, database names, or system info
- [ ] Handle all error paths (don't swallow exceptions)

**Implementation Pattern:**
```dart
try {
  await performOperation();
} on SpecificException catch (e, stackTrace) {
  // Log detailed info for debugging
  logger.error('Operation failed', error: e, stackTrace: stackTrace);
  // Show generic message to user
  showUserMessage('Unable to complete operation. Please try again.');
} catch (e, stackTrace) {
  // Catch-all for unexpected errors
  logger.error('Unexpected error', error: e, stackTrace: stackTrace);
  showUserMessage('An unexpected error occurred. Please try again.');
}
```

### 6. Secure Configuration

**Configuration Security:**
- Never hardcode secrets in source code
- Use environment variables for sensitive configuration
- Keep secrets out of version control
- Use different credentials for different environments
- Implement secrets rotation

**Example (.env file):**
```bash
# Add to .gitignore!
FIREBASE_API_KEY=your_key_here
DATABASE_URL=your_url_here
```

### 7. Dependency Management

**Security Practices:**
- Keep dependencies updated
- Use `dart pub outdated` regularly
- Review dependencies for known vulnerabilities
- Pin dependency versions in production
- Use minimal dependencies (reduce attack surface)

### 8. Logging and Monitoring

**Secure Logging:**
- Never log sensitive data (passwords, tokens, PII)
- Log security events (failed logins, access violations)
- Use structured logging for easier analysis
- Implement log integrity protection
- Set up alerts for suspicious activity

**What NOT to Log:**
- Passwords or credentials
- Session tokens or API keys
- Credit card numbers
- Personal health information
- Full user details (log IDs instead)

## Language-Specific Guidelines

### Dart/Flutter

**Secure HTTP Requests:**
```dart
import 'package:http/http.dart' as http;

// Use HTTPS only
final response = await http.get(
  Uri.https('api.example.com', '/endpoint'),
  headers: {'Authorization': 'Bearer $token'},
);
```

**Secure Storage:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Store tokens securely
await storage.write(key: 'auth_token', value: token);

// Read securely
final token = await storage.read(key: 'auth_token');
```

**Certificate Pinning:**
```dart
// For high-security applications, implement certificate pinning
// Use packages like http_certificate_pinning
```

## Security Checklist

Before submitting code:

- [ ] No secrets in code (use environment variables)
- [ ] Error messages don't leak implementation details
- [ ] All user input is validated
- [ ] Output is properly encoded for context
- [ ] Authentication follows secure patterns
- [ ] Session management is secure
- [ ] Dependencies are up to date
- [ ] No sensitive data in logs
- [ ] HTTPS used for all network calls
- [ ] Security headers configured (for web)

## References

- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [OWASP Developer Guide](https://owasp.org/www-project-developer-guide/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
