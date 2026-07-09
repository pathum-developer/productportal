# Contributing to Product Portal

Thank you for your interest in contributing to Product Portal! We welcome contributions from the community.

## 📋 Code of Conduct

Be respectful, inclusive, and professional. We're committed to creating a welcoming environment for all contributors.

---

## 🚀 Getting Started

### 1. Fork & Clone
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/productportal.git
cd productportal

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/productportal.git
```

### 2. Create Feature Branch
```bash
# Fetch latest
git fetch upstream

# Create branch from latest develop/main
git checkout -b feature/your-feature-name upstream/main
```

### 3. Make Changes
- Follow project structure conventions
- Write clean, readable code
- Add comments for complex logic
- Follow Java naming conventions (camelCase for variables, PascalCase for classes)

### 4. Commit with Conventional Commits
```bash
# Format: <type>(<scope>): <description>

git commit -m "feat(user): add pagination to getAllUsersByStatus endpoint"
git commit -m "fix(auth): resolve JWT token refresh issue"
git commit -m "refactor(repository): optimize N+1 query in findAllByIdInFetch"
git commit -m "docs(README): update API documentation"
git commit -m "test(user): add integration tests for pageable endpoint"
```

**Commit Types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code refactoring
- `perf:` — Performance improvements
- `docs:` — Documentation
- `test:` — Test additions/modifications
- `chore:` — Build, dependencies, tooling

### 5. Keep Branch Updated
```bash
git fetch upstream
git rebase upstream/main
```

### 6. Push & Create Pull Request
```bash
git push origin feature/your-feature-name
```
- Go to GitHub repository
- Click **Compare & pull request**
- Fill PR template
- Submit

---

## ✅ Pull Request Guidelines

### PR Title Format
```
[TYPE] Brief description

feat: Add feature X
fix: Resolve issue Y
refactor: Improve performance of Z
```

### PR Description
Include:
- **What:** Summary of changes
- **Why:** Motivation/context
- **How:** Technical approach
- **Testing:** How to test the changes
- **Checklist:**
  - [ ] Code follows project style
  - [ ] Tests added/updated
  - [ ] Documentation updated
  - [ ] No breaking changes
  - [ ] Related issues linked

**Example:**
```markdown
## What
Add custom sorting support to pageable user endpoint

## Why
Users need flexibility to sort by different columns for better UX

## How
- Created UserSortColumn enum for whitelisting columns
- Added SortValidator utility for SQL injection prevention
- Updated controller to accept sort parameters via Pageable

## Testing
Tested in Postman:
- ?sort=username,desc
- ?sort=email,asc
- ?sort=firstName,asc&sort=lastName,asc

Closes #42
```

---

## 🧪 Testing Requirements

- **Unit Tests:** Required for service layer
- **Integration Tests:** Required for controllers
- **Performance Tests:** For performance-critical paths
- **Coverage:** Maintain >70% code coverage

```bash
# Run tests
mvn clean test

# Run with coverage
mvn clean test jacoco:report

# View coverage report
# Open target/site/jacoco/index.html in browser
```

---

## 📝 Code Style

### Java Conventions
```java
// Class names: PascalCase
public class UserServiceImpl {
    
    // Constants: UPPER_SNAKE_CASE
    private static final String DEFAULT_ROLE = "BUYER";
    
    // Variables: camelCase
    private String username;
    private int pageSize;
    
    // Methods: camelCase
    public void getAllUsersByStatus(String status) {
        // Implementation
    }
}
```

### Formatting
- Indentation: 4 spaces
- Line length: Max 120 characters
- Imports: Organized, no wildcards
- Comments: Clear, concise, English only

### Best Practices
- Use try-with-resources for auto-closeable resources
- Prefer immutability when possible
- Avoid null; use Optional
- Use descriptive variable/method names
- Keep methods focused (single responsibility)
- Add JavaDoc for public APIs

---

## 🏗️ Architecture Guidelines

### Layering
1. **Controller** — REST endpoints, request validation
2. **Service** — Business logic, transactions
3. **Repository** — Data access, queries
4. **Entity** — Domain models, database mapping

### Naming Conventions
```
Controllers:  {Resource}Controller
Services:     {Domain}Service, {Domain}ServiceImpl
Repositories: {Domain}Repository
Entities:     {Domain}, {Domain}Status, etc.
DTOs:         {Purpose}Request, {Purpose}Response
```

### Query Optimization
- Use fetch-joins for associations (avoid N+1)
- Implement two-query pagination for large datasets
- Add @EntityGraph for eager loading
- Validate sort parameters (prevent SQL injection)

---

## 📚 Project-Specific Conventions

### Pagination
Use two-query pattern:
1. Fetch paginated IDs (lightweight)
2. Fetch full entities with fetch-joins

```java
// ✅ Good
Page<Long> ids = repository.findIdsByStatus(status, pageable);
List<Entity> entities = repository.findAllByIdInFetch(ids.getContent());

// ❌ Avoid
Page<Entity> page = repository.findAllByStatus(status, pageable); // N+1 queries
```

### Sorting
Validate sort parameters:
```java
// ✅ Good
Pageable validatedPageable = SortValidator.validateAndSanitizeSort(pageable);

// ❌ Avoid
query.append(" ORDER BY " + sortColumn); // SQL injection risk
```

### Error Handling
Use custom exceptions:
```java
// ✅ Good
throw new ResourceNotFoundException("User not found: " + username);
throw new ResourceConflictException("Email already exists");

// ❌ Avoid
throw new RuntimeException("Error");
```

---

## 🔄 Review Process

### What Reviewers Look For
- [ ] Code quality & readability
- [ ] Architecture & design patterns
- [ ] Test coverage
- [ ] Performance implications
- [ ] Documentation
- [ ] Security considerations
- [ ] Breaking changes

### Addressing Review Comments
```bash
# Make requested changes
# Don't force-push; add commits (easier to review changes)
git add .
git commit -m "Address review: Improve error handling in getUserByUsername"

# After approval
git rebase -i upstream/main  # Squash if needed
git push origin feature/your-feature-name
```

---

## 📦 Release Process

1. Update version in `pom.xml`
2. Update `CHANGELOG.md`
3. Create release branch: `release/v1.0.0`
4. Create PR to `main`
5. After merge, create GitHub Release
6. Tag version: `git tag v1.0.0`

---

## 🆘 Help & Questions

- **Issues:** Use GitHub Issues for bugs/features
- **Discussions:** Use GitHub Discussions for questions
- **Email:** support@example.com
- **Documentation:** See [README.md](README.md)

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT).

---

**Happy contributing! 🚀**
