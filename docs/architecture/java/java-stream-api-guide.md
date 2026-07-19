# Java Stream API Guide

## Purpose

Use this guide when you need to process collections in Java using readable, declarative pipelines instead of manual loops.

This document is based on the `stream()` usage in `SecurityPathProperties`, especially these responsibilities:

- combine default security path groups
- remove blank values
- trim configured path strings
- remove duplicates
- collect invalid values for startup validation

The goal is to make Java Stream usage clear, safe, and maintainable in enterprise code.

---

## Core idea

A Java `Stream` is a pipeline for processing elements from a source such as a `List`, `Set`, array, or generated sequence.

The typical flow is:

```text
source collection
 -> stream()
 -> intermediate operations
 -> terminal operation
 -> result
```

Example:

```java
List<String> normalizedPaths = paths.stream()
        .filter(StringUtils::hasText)
        .map(String::trim)
        .distinct()
        .toList();
```

What this means:

```text
paths.stream()
= start a stream from the list

filter(StringUtils::hasText)
= keep only non-empty text values

map(String::trim)
= transform each value by trimming whitespace

distinct()
= remove duplicate values

toList()
= produce the final List
```

Important rule:

```text
Intermediate operations do not execute until a terminal operation runs.
```

In the example above, the terminal operation is:

```java
toList()
```

---

## When to use it

Use streams when the code naturally reads as a pipeline:

- filter values
- transform values
- remove duplicates
- collect matching records
- check whether any/all/no items match a rule
- group or map collection values
- build immutable result lists

Good use case:

```java
List<String> invalidPaths = paths.stream()
        .filter(path -> !path.startsWith("/"))
        .toList();
```

This reads directly as:

```text
from all paths, keep paths that do not start with '/', then return them as a list
```

Avoid streams when:

- the logic has many branches
- mutation is the main purpose
- readability is worse than a loop
- exception handling inside the pipeline becomes awkward
- performance profiling proves a tight loop is better
- you need step-by-step debugging of complex procedural logic

---

## Coding example

### Imperative version

```java
private static List<String> normalize(List<String> paths) {
    if (paths == null) {
        return List.of();
    }

    List<String> normalizedPaths = new ArrayList<>();

    for (String path : paths) {
        if (!StringUtils.hasText(path)) {
            continue;
        }

        String trimmedPath = path.trim();
        if (!normalizedPaths.contains(trimmedPath)) {
            normalizedPaths.add(trimmedPath);
        }
    }

    return List.copyOf(normalizedPaths);
}
```

### Stream version

```java
private static List<String> normalize(List<String> paths) {
    if (paths == null) {
        return List.of();
    }

    return paths.stream()
            .filter(StringUtils::hasText)
            .map(String::trim)
            .distinct()
            .toList();
}
```

The stream version is shorter and more declarative. Each operation describes one transformation step.

---

## Project-specific example

Current project class:

```java
@ConfigurationProperties(prefix = "security.paths")
public record SecurityPathProperties(
        List<String> permitAll,
        List<String> jwtBypass,
        List<String> authenticated
) {
}
```

### Example 1: Combining default path groups

```java
private static final List<String> DEFAULT_PERMIT_ALL_PATHS = Stream.concat(
                DEFAULT_PUBLIC_API_PATHS.stream(),
                DEFAULT_API_DOCUMENTATION_PATHS.stream())
        .toList();
```

What happens:

```text
DEFAULT_PUBLIC_API_PATHS.stream()
= stream over public API paths

DEFAULT_API_DOCUMENTATION_PATHS.stream()
= stream over Swagger/OpenAPI paths

Stream.concat(...)
= join both streams into one stream

toList()
= produce the final default permit-all list
```

### Example 2: Normalizing configured paths

```java
List<String> normalizedPaths = paths.stream()
        .filter(StringUtils::hasText)
        .map(String::trim)
        .distinct()
        .toList();
```

What this protects against:

```text
null list       -> handled before stream starts
blank values    -> removed by filter()
extra spaces    -> removed by trim()
duplicates      -> removed by distinct()
mutable result  -> avoided by Stream.toList()
```

### Example 3: Collecting invalid paths before failing

```java
List<String> invalidPaths = paths.stream()
        .filter(path -> !path.startsWith("/"))
        .toList();

if (!invalidPaths.isEmpty()) {
    throw new IllegalArgumentException(
            "security.paths." + propertyName + " entries must start with '/': " + invalidPaths);
}
```

Why this is better than throwing immediately:

```text
It reports all invalid paths at once.
```

That is better operational behavior because the developer or DevOps engineer can fix the full configuration problem in one pass.

### Example 4: Validating unsafe JWT-bypass configuration

```java
List<String> protectedBypassPaths = jwtBypassPaths.stream()
        .filter(path -> !permitAllPaths.contains(path))
        .toList();

if (!protectedBypassPaths.isEmpty()) {
    throw new IllegalArgumentException(
            "security.paths.jwt-bypass entries must also be listed in security.paths.permit-all: "
                    + protectedBypassPaths);
}
```

This prevents a dangerous configuration:

```text
JWT filter skips a path
but Spring Security does not explicitly permit that path
```

The stream makes the rule auditable:

```text
find every bypass path that is not explicitly public
```

---

## Execution flow

For this code:

```java
List<String> normalizedPaths = paths.stream()
        .filter(StringUtils::hasText)
        .map(String::trim)
        .distinct()
        .toList();
```

The execution flow is:

```text
1. paths.stream()
   Creates a sequential stream from the List.

2. filter(StringUtils::hasText)
   Defines a rule to keep only text values.

3. map(String::trim)
   Defines a transformation for each kept value.

4. distinct()
   Defines duplicate-removal based on equals().

5. toList()
   Starts the pipeline and creates the final List.
```

Important: steps 2, 3, and 4 are intermediate operations. They are lazy.

Nothing is actually processed until:

```java
toList()
```

is called.

---

## Enterprise best practices

### Keep stream pipelines readable

Good:

```java
return paths.stream()
        .filter(StringUtils::hasText)
        .map(String::trim)
        .distinct()
        .toList();
```

Avoid:

```java
return paths.stream().filter(p -> p != null && !p.isBlank()).map(p -> p.trim()).filter(p -> someComplexRule(p)).map(p -> transformAgain(p)).distinct().toList();
```

If the pipeline is hard to read, extract named methods.

### Prefer method references when they improve clarity

Good:

```java
.map(String::trim)
```

Also acceptable:

```java
.map(path -> path.trim())
```

Use the form that makes intent clearer.

### Keep stream operations side-effect free

Avoid mutating external state inside a stream:

```java
List<String> result = new ArrayList<>();

paths.stream()
        .filter(StringUtils::hasText)
        .forEach(result::add);
```

Prefer collecting the result:

```java
List<String> result = paths.stream()
        .filter(StringUtils::hasText)
        .toList();
```

### Do not reuse a stream

Wrong:

```java
Stream<String> stream = paths.stream();

List<String> valid = stream.filter(path -> path.startsWith("/")).toList();
List<String> invalid = stream.filter(path -> !path.startsWith("/")).toList();
```

A stream is intended to be consumed once.

Correct:

```java
List<String> valid = paths.stream()
        .filter(path -> path.startsWith("/"))
        .toList();

List<String> invalid = paths.stream()
        .filter(path -> !path.startsWith("/"))
        .toList();
```

### Be careful with parallel streams

Do not use `parallelStream()` by default.

For most Spring Boot request-processing and configuration-validation code, sequential streams are the right choice.

Use parallel streams only when:

- the workload is CPU-heavy
- the collection is large enough to justify parallel overhead
- the operations are stateless
- the code has been benchmarked
- thread-safety is clear

### Understand `toList()`

`Stream.toList()` returns an unmodifiable list in modern Java.

That is good for configuration code because configuration should not be mutated after startup.

If a mutable list is required, use:

```java
List<String> mutablePaths = paths.stream()
        .filter(StringUtils::hasText)
        .collect(Collectors.toCollection(ArrayList::new));
```

---

## Testing template

Test the behavior, not the stream implementation.

### Test normalization

```java
@Test
void configuredPathsShouldBeTrimmedAndDeduplicated() {
    SecurityPathProperties properties = new SecurityPathProperties(
            List.of(" /api/public ", "/api/public", " "),
            List.of(" /api/public "),
            List.of(" /api/** ", "/api/**"));

    assertThat(properties.permitAll()).containsExactly("/api/public");
    assertThat(properties.jwtBypass()).containsExactly("/api/public");
    assertThat(properties.authenticated()).containsExactly("/api/**");
}
```

### Test invalid values are collected

```java
@Test
void configuredPathsMustBeAbsolute() {
    assertThatThrownBy(() -> new SecurityPathProperties(
            List.of("api/public"),
            List.of(),
            List.of("/api/**")))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("security.paths.permit-all")
            .hasMessageContaining("must start with '/'");
}
```

### Test unsafe combinations

```java
@Test
void jwtBypassPathsMustAlsoBePermitAllPaths() {
    assertThatThrownBy(() -> new SecurityPathProperties(
            List.of("/api/auth/login"),
            List.of("/api/admin/**"),
            List.of("/api/**")))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("security.paths.jwt-bypass")
            .hasMessageContaining("/api/admin/**");
}
```

---

## Common mistakes

### Mistake 1: Forgetting the terminal operation

Wrong:

```java
paths.stream()
        .filter(StringUtils::hasText)
        .map(String::trim);
```

This does nothing useful because no terminal operation is called.

Correct:

```java
List<String> normalizedPaths = paths.stream()
        .filter(StringUtils::hasText)
        .map(String::trim)
        .toList();
```

### Mistake 2: Calling `stream()` on a null list

Wrong:

```java
return paths.stream()
        .map(String::trim)
        .toList();
```

If `paths` is null, this throws `NullPointerException`.

Correct:

```java
if (paths == null) {
    return List.of();
}

return paths.stream()
        .map(String::trim)
        .toList();
```

### Mistake 3: Using streams for unclear complex logic

If the stream becomes unreadable, use a loop or extract methods.

Readable code is more important than forcing a stream.

### Mistake 4: Using `peek()` for business logic

Avoid:

```java
paths.stream()
        .peek(path -> audit(path))
        .filter(StringUtils::hasText)
        .toList();
```

`peek()` is mainly useful for debugging. Business behavior should not depend on it.

### Mistake 5: Assuming `toList()` returns a mutable list

Wrong assumption:

```java
List<String> result = paths.stream().toList();
result.add("/api/new");
```

This can throw:

```text
UnsupportedOperationException
```

Use a collector if a mutable list is required.

---

## Interview questions and answers

### Q1: What does `stream()` do?

It creates a stream pipeline from a source collection. The stream allows aggregate operations such as filtering, mapping, matching, reducing, and collecting.

### Q2: What is the difference between intermediate and terminal operations?

Intermediate operations return another stream and are lazy.

Examples:

```java
filter()
map()
distinct()
sorted()
```

Terminal operations produce a result or side effect and trigger execution.

Examples:

```java
toList()
collect()
count()
anyMatch()
forEach()
```

### Q3: Why does `SecurityPathProperties` use `filter(StringUtils::hasText)`?

To remove null, empty, and blank path values before trimming and validation.

### Q4: Why use `distinct()`?

To remove duplicate configured paths so the security rule lists are stable and predictable.

### Q5: What does `map(String::trim)` do?

It transforms each string by removing leading and trailing whitespace.

### Q6: Why is `toList()` a good terminal operation for config?

It produces an unmodifiable result list, which fits immutable configuration objects.

### Q7: Should streams always replace loops?

No. Use streams when the pipeline is readable. Use loops when control flow is clearer.

### Q8: Can a stream be reused?

No. A stream should be consumed once. Create a new stream from the source collection for another pipeline.

### Q9: When should `parallelStream()` be used?

Only for proven CPU-heavy workloads with stateless operations and measured performance benefit. Do not use it by default in Spring Boot request or config code.

### Q10: Why does validation collect invalid paths into a list before throwing?

It improves operational feedback by reporting all invalid configuration values at once.

---

## Related concepts to learn next

1. Java functional interfaces
2. Lambda expressions
3. Method references
4. `Predicate`, `Function`, and `Consumer`
5. `Collectors`
6. Immutable collections
7. `Optional`
8. Sequential vs parallel streams
9. Big-O performance of `List.contains()`
10. Fail-fast startup validation

---

## Summary

`stream()` is a clean way to process collection data through a pipeline.

In this project, it is used well in `SecurityPathProperties` because the operations are simple and declarative:

```text
filter blank values
trim strings
remove duplicates
collect invalid values
validate unsafe path combinations
```

Enterprise rule:

```text
Use streams when they make transformation and validation logic easier to read.
Do not use streams just to avoid writing loops.
```

---

## References

- [Oracle Java SE 25 `Stream` API](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/stream/Stream.html)
- [Oracle Java SE 25 `Collection.stream()` API](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/Collection.html#stream())
- [Oracle Java SE 25 `Stream.toList()` API](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/stream/Stream.html#toList())
- [Oracle Java SE 25 `Stream.concat(...)` API](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/stream/Stream.html#concat(java.util.stream.Stream,java.util.stream.Stream))
