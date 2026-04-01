# 📋 Code & Documentation Standards

## Code Standards by Language

### Swift/iOS
- **Style:** Swift API Design Guidelines
- **Minimum:** iOS 16+
- **Structure:** MVVM pattern preferred
- **Error Handling:** Result types, throw, try/catch
- **Async:** async/await only (no callbacks)
- **Naming:** camelCase for variables, PascalCase for types
- **Comments:** Documentation comments (///)
- **Testing:** Unit tests required for all logic

### Python/Backend
- **Style:** PEP 8
- **Version:** Python 3.11+
- **Type Hints:** Mandatory on all functions
- **Error Handling:** Custom exceptions
- **Async:** async/await for I/O
- **Naming:** snake_case for functions, PascalCase for classes
- **Comments:** Docstrings (Google style)
- **Testing:** Unit tests for scrapers and utilities

## Documentation Standards

### File Documentation
```
Each file must have:
- File purpose (1 line at top)
- Author/date
- Key classes/functions
- Usage examples (if applicable)
```

### Function Documentation
```
def search_prices(product_name: str) -> dict:
    """
    Search for product prices across multiple sources.
    
    Args:
        product_name: The product to search for
        
    Returns:
        Dictionary with cheapest price and alternatives
        
    Raises:
        ValueError: If product_name is empty
        ScraperError: If all sources fail
    """
```

### Commit Messages
```
Format: [SCOPE] TITLE

Examples:
[iOS] Add camera permission handling
[Backend] Implement Mercado Libre scraper
[DevOps] Set up CI/CD pipeline

Body: Explain what and why (not how)
```

## Code Review Standards

### Before Submitting PR
- [ ] Tests written and passing
- [ ] Code follows language standards
- [ ] No commented-out code
- [ ] No console.log/print debugging
- [ ] Documentation updated
- [ ] Commit messages clear

### Minimum Reviewers
- 1 from same domain (iOS, Backend, DevOps)
- 1 from different domain

### Approval Criteria
- ✅ Tests passing
- ✅ Code standards followed
- ✅ Logic makes sense
- ✅ No performance regression
- ✅ Documentation clear

---

**Last Updated:** April 1, 2026
