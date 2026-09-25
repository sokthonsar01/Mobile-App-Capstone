# AGENTS.md — Flutter Frontend Engineering Standards

You are the coding agent for this Flutter app's frontend. This file is not a
style suggestion — it is the standard every file you write or touch must
meet. The backend is already organized well; the frontend is not, and your
job is to bring it up to that bar without creating a second mess along the
way.

---

## 0. Prime Directive: Understand Before You Write

Do not write a line of code you cannot explain. Before implementing
anything, you must be able to answer, in plain language:

- What problem is this piece of code solving?
- Why does it belong here, in this file, at this layer?
- What will break, and where, if the input/state/API response is not what
  I expect?

**"It works" is not the bar.** Code that runs but was assembled without
understanding *why* it works is a liability — it will break under a
slightly different input, and whoever touches it next (including future-you)
will have to reverse-engineer it before they can safely change it. If you
can't explain a piece of code you're about to write, stop and work out the
reasoning first, or ask a clarifying question instead of guessing.

This applies with equal force to *editing* existing messy code: read and
understand the surrounding code's actual behavior before changing it.
Pattern-matching to "code that looks similar" is how bugs get copy-pasted.

---

## 1. Core Principles

### SOLID
- **S — Single Responsibility.** One class/widget/file, one reason to
  change. A screen widget's reason to change is "the layout changed" —
  not "the API shape changed" or "the validation rule changed."
- **O — Open/Closed.** Add new behavior by adding new code (new subclass,
  new strategy, new case), not by editing a long `if/else` or `switch`
  chain that every feature has to add a branch to.
- **L — Liskov Substitution.** A subtype must be usable anywhere its
  parent type is expected, without the caller needing to know which
  concrete type it got.
- **I — Interface Segregation.** Don't make a widget or class depend on
  methods it never uses. Prefer several small abstract contracts over one
  bloated one.
- **D — Dependency Inversion.** Widgets and controllers depend on
  abstractions (a repository interface), not concrete implementations
  (a specific `http.Client` call or Firestore SDK call) buried inside the
  widget. Inject dependencies via constructor or a provider — never
  instantiate a data source directly inside a widget.

### DRY (Don't Repeat Yourself)
If the same logic, validation, or widget tree appears in two places,
extract it. Copy-pasting between screens is the #1 source of "fixed it in
one place, forgot the other" bugs.

### KISS / YAGNI
Build what the current requirement actually needs. Don't add
configurability, abstraction layers, or generic frameworks for
hypothetical future features. A simpler solution that's easy to change
later beats a "flexible" one that's hard to understand now.

### Separation of Concerns
Three layers, always:
- **Presentation** — widgets. Render state, forward user actions. Nothing
  else.
- **Domain/logic** — controllers, notifiers, use-cases. Business rules,
  validation, orchestration. No `Widget`, no `BuildContext` dependency.
- **Data** — repositories, API/data sources, models. Talks to the network
  or local storage, returns plain data/domain objects.

A screen widget should never call an API, parse JSON, or contain a
validation rule directly. If it does, that logic belongs one layer down.

### Other low-level principles to hold to
- **Composition over inheritance** — build widgets by composing smaller
  widgets, not by deep inheritance chains.
- **Law of Demeter** — a widget should talk to its direct collaborators,
  not reach through `a.b.c.d` to grab something three objects away.
- **Immutability by default** — use `final`, `const` constructors, and
  immutable models. Mutable shared state is where most Flutter rebuild
  bugs come from.
- **Fail fast, don't swallow errors** — surface errors up to where they
  can be handled or shown to the user; don't catch-and-ignore.

---

## 2. Mandatory Folder Structure

```
lib/
  core/                 # app-wide constants, theme, error types, utils
  shared/               # reusable widgets used by 2+ features
  features/
    <feature_name>/
      data/             # models, API/data sources, repository impl
      domain/           # (if logic is non-trivial) entities, use-cases
      presentation/
        screens/
        widgets/
        controller/      # or notifier/cubit/bloc — your state layer
  main.dart
```

Every new feature follows this shape. Do not add a new top-level folder
that doesn't fit this pattern without a clear reason stated in your
summary.

---

## 3. Hard Limits (non-negotiable)

- **No file over ~200 lines** (generated files excluded). If a file is
  approaching this, split it *before* it crosses the line, not after.
- **No `build()` method over ~40 lines.** Extract sub-widgets into their
  own classes or private `Widget _buildX()` methods once it grows past a
  screenful.
- **No function doing more than one thing.** If you need "and" to
  describe what a function does, split it.
- **One public class/widget per file.** Small private helper widgets used
  only inside that file are fine.
- **No business logic inside a widget class.** If a widget contains a
  validation rule, a data transformation, or an API call, that's a defect
  — move it to the controller/domain layer.

---

## 4. State Management

Pick **one** approach for the whole app (Provider, Riverpod, or Bloc/Cubit
— whichever the project already leans toward) and use it consistently.
Regardless of which:
- Widgets read state and dispatch events/intents. They never mutate state
  directly or hold business logic.
- The state layer (notifier/cubit/controller) never imports `flutter/material.dart`
  widget classes — it should be plain Dart, testable without a widget tree.

---

## 5. Naming & Style

- Descriptive names — no `data`, `temp`, `val`, `handle2`. A name should
  make a comment unnecessary.
- Booleans read as a question: `isLoading`, `hasError`, `canSubmit`.
- No magic numbers or hardcoded strings scattered in widget code — pull
  them into `core/constants/`.
- File names: `snake_case.dart`. Classes/widgets: `PascalCase`. Variables
  and functions: `camelCase`.

---

## 6. Comments & Documentation

- Comments explain **why**, not **what**. If the code needs a comment to
  say what it does, rewrite the code to be clearer instead.
- Every public class and non-trivial function gets a one-line `///` doc
  comment stating its purpose.
- No commented-out dead code left behind — delete it (version control
  already remembers it).

---

## 7. Explicitly Banned Patterns

- "God widgets" — one file mixing UI, API calls, and business logic
  (this is almost certainly what the current frontend has; do not add to
  it).
- Copy-pasted widget trees or logic instead of a shared/extracted version.
- Hardcoded colors, sizes, and strings scattered file-to-file instead of
  centralized theme/constants.
- `try/catch` blocks that swallow the error silently with no rethrow, no
  log, no user-facing message.
- Deeply nested widget trees/conditionals (4+ levels) instead of
  extraction into named widgets.
- Passing `BuildContext` down into the domain/data layer.
- Global mutable singletons used as a substitute for proper state
  management or dependency injection.

---

## 8. The Quick-Fix Disclosure Protocol

This is the rule that matters most for this project: **you are allowed to
take a shortcut, but you are never allowed to hide one.**

If you write something incomplete, simplified, or "good enough for now"
to unblock progress:

1. Mark it in code with a clear tag: `// HACK:` or `// TEMP:`.
2. In that comment, state: what was skipped, why, and what the correct
   fix would look like.
3. State it again, plainly, in your response summary — don't let it sit
   silently in a diff where it'll be forgotten.

A shortcut with no disclosure is treated as a defect, even if it runs
correctly today. The failure mode this project is trying to avoid is
exactly this: code that "works for now" and quietly becomes load-bearing
until it breaks or blocks a refactor.

---

## 9. Self-Review Checklist (run before calling anything done)

- [ ] Can I explain every line I just wrote, and why it's needed?
- [ ] Does any touched file/function exceed the size limits in §3?
- [ ] Is there duplicated logic here that should be extracted (DRY)?
- [ ] Does any widget mix rendering with business logic or a network call?
- [ ] Are magic numbers/strings replaced with named constants?
- [ ] Would a teammate understand this file without me explaining it out
      loud?
- [ ] Did I leave a `HACK`/`TEMP` without a full explanation attached?
- [ ] Is this logic testable on its own, without spinning up unrelated
      widgets?

---

## 10. Refactoring the Existing Messy Code

When touching an existing 200–300+ line file:

1. **Don't rewrite the whole file at once.** Isolate the piece relevant to
   the current task first.
2. **Extract one responsibility at a time** out of the god-file into its
   own widget/class in the correct layer (§1, §2).
3. **Bring new code up to this standard immediately** — don't match the
   old file's style "for consistency." The old style is what we're moving
   away from.
4. **Flag what you didn't have time to fix.** Leave a `// REFACTOR:` note
   explaining what's still tangled and why, rather than silently leaving
   it and saying nothing.

---

## 11. Example: Applying This in Practice

**Before (violates SRP, untestable, hardcoded):**
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: http.get(Uri.parse("https://api.example.com/user/1")),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final data = jsonDecode(snapshot.data.body);
        return Container(
          color: Color(0xFF3366FF),
          child: Text(data['name']),
        );
      },
    );
  }
}
```

**After (layers separated, each piece testable and readable on its own):**
```dart
// data/user_repository.dart
class UserRepository {
  UserRepository(this._client);
  final ApiClient _client;

  Future<User> fetchUser(String id) async {
    final response = await _client.get('/user/$id');
    return User.fromJson(response);
  }
}

// presentation/controller/profile_controller.dart
class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);
  final UserRepository _repository;

  User? user;
  bool isLoading = false;

  Future<void> loadUser(String id) async {
    isLoading = true;
    notifyListeners();
    user = await _repository.fetchUser(id);
    isLoading = false;
    notifyListeners();
  }
}

// presentation/screens/profile_screen.dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    if (controller.isLoading) return const LoadingIndicator();
    return ProfileView(user: controller.user);
  }
}
```

Each piece can now be understood, tested, and changed without touching
the others. That's the bar for every file in this app going forward.