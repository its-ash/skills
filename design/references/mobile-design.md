> **Parent skill:** [`design`](../SKILL.md). This is a sub-skill; follow `design` for the shared workflow and load this only when the task needs it.

# Mobile Design

Design mobile apps as touch‑first, battery‑conscious experiences that respect each platform’s conventions. Mobile is **not** a small desktop; treat screen size, input method, and connectivity as core constraints.

---

## When to use
- Building a new iOS, Android, or cross‑platform app (React Native, Flutter, SwiftUI, Jetpack Compose).
- Refactoring an existing mobile codebase for performance or usability.
- Creating design specifications that must align with platform guidelines.

---

## Core Principles
| Principle | Action |
|---|---|
| **Touch‑first** | Minimum touch target: 44 pt (iOS) / 48 dp (Android). Keep 8‑12 px spacing between interactive elements. |
| **Battery‑aware** | Avoid unnecessary background work. Use native drivers for animations. |
| **Platform‑respectful** | Follow Human Interface Guidelines (iOS) or Material Design 3 (Android). Use native navigation gestures and UI components. |
| **Offline‑capable** | Cache data locally, show graceful degradation when network is unavailable. |
| **Accessibility** | Provide labels, dynamic type support, and sufficient contrast. |

---

## Platform Decision Matrix
```
UNIFY (same on both)          DIVERGE (platform‑specific)
───────────────────────      ───────────────────────────────────────
Business logic                ✅ always shared
Data layer                    ✅ always shared
Core features                 ✅ always shared
Navigation                    iOS: edge‑swipe back   Android: system back button
Gestures                      iOS: native gestures  Android: native gestures
Icons                         iOS: SF Symbols       Android: Material Icons
Date pickers                  iOS: UIDatePicker      Android: MaterialDatePicker
Modals / sheets               iOS: bottom sheet     Android: dialog / bottom sheet
Typography                    iOS: SF Pro / Compact Android: Roboto (or system font)
```

### Quick Platform Defaults
| Element | iOS | Android |
|---|---|---|
| Primary font | SF Pro / SF Compact | Roboto |
| Min touch target | 44 pt × 44 pt | 48 dp × 48 dp |
| Back navigation | Edge‑swipe left | System back button / gesture |
| Bottom tab icons | SF Symbols | Material Symbols |
| Action sheet | UIActionSheet (bottom) | Bottom Sheet / Dialog |
| Progress indicator | UIActivityIndicator (spinner) | Linear progress bar |
| Pull‑to‑refresh | UIRefreshControl | SwipeRefreshLayout |

---

## Touch & UX Psychology
- **Fitts’ Law**: Finger contact area ≈ 7 mm. Ensure targets are at least 44‑48 px to keep movement time low.
- **Thumb zone**: Place primary actions within the natural arc of the thumb (bottom‑center). Destructive actions belong toward the top‑right (iOS) or top‑left (Android) where they are harder to reach accidentally.
- **One‑handed use**: Design for a single hand; avoid placing critical controls at the far top‑right corner on large phones.
- **Cognitive load**: Mobile users handle one task at a time. Keep screens focused, avoid hover‑only interactions, and provide clear loading / error feedback.

---

## Performance Principles
### React Native
```tsx
// Memoized list item
const ListItem = React.memo(({ item }: { item: Item }) => (
  <View style={styles.item}>
    <Text>{item.title}</Text>
  </View>
));

const renderItem = useCallback(
  ({ item }: { item: Item }) => <ListItem item={item} />, []);

<FlatList
  data={items}
  renderItem={renderItem}
  keyExtractor={item => item.id}
  getItemLayout={(data, index) => ({ length: ITEM_HEIGHT, offset: ITEM_HEIGHT * index, index })}
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  windowSize={5}
/>
```
- Use **FlatList / FlashList** for long lists, not ScrollView.
- Memoize `renderItem` and wrap list rows with `React.memo`.
- Provide `keyExtractor` with stable IDs; avoid index keys.
- Supply `getItemLayout` when item height is fixed.
- Enable `useNativeDriver: true` for all animated values.
- Remove `console.log` statements from production builds.

### Flutter
```dart
// Const constructor prevents unnecessary rebuilds
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Static content'),
        MyConstantWidget(),
      ],
    );
  }
}

// Targeted state with ValueListenableBuilder
ValueListenableBuilder<int>(
  valueListenable: counter,
  builder: (context, value, child) => Text('\$value'),
  child: const ExpensiveWidget(), // child not rebuilt
);
```
- Mark widgets with `const` whenever possible.
- Use `ValueListenableBuilder`, `StreamBuilder`, or `Provider` to limit rebuild scope.
- Prefer `ListView.builder` with `itemExtent` for fixed‑height lists.
- Keep animations on the GPU: animate `transform` and `opacity`; avoid animating `width`, `height`, `margin`, or `padding`.

---

## Anti‑Patterns to Avoid
### Performance
| Bad practice | Why it fails | Correct approach |
|---|---|---|
| ScrollView for long lists | Renders all items, high memory use | Use FlatList / ListView.builder with virtualization |
| Inline `renderItem` function | New function each render, forces re‑render of all rows | Memoize with `useCallback` and `React.memo` |
| Missing `keyExtractor` or using index as key | Reorder bugs, unnecessary renders | Use stable, unique IDs |
| `setState` everywhere | Triggers full component tree rebuild | Keep state local, lift only when needed |
| Native driver disabled | Animations compete with JS thread | Set `useNativeDriver: true` |

### Touch / UX
| Bad practice | Impact | Correct approach |
|---|---|---|
| Target < 44 px (iOS) / 48 dp (Android) | Missed taps, frustration | Ensure minimum size for all tappable elements |
| Spacing < 8 px between targets | Accidental taps | Keep at least 8‑12 px gap |
| Gesture‑only actions | Excludes motor‑impaired users | Provide a visible button alternative |
| No loading or error states | Users think app is frozen | Show progress indicators and retry options |
| No offline handling | Crashes on network loss | Cache data, show offline UI |
| Ignoring platform conventions | Confuses users | Follow HIG (iOS) or Material Design (Android) |

### Security
| Bad practice | Risk | Correct approach |
|---|---|---|
| Storing tokens in `AsyncStorage` / plain SharedPreferences | Easy extraction on rooted/jail‑broken devices | Use SecureStore (iOS) / EncryptedSharedPreferences (Android) |
| Hard‑coding API keys | Reverse‑engineered from binaries | Load from secure environment variables or server‑side proxy |
| Skipping SSL pinning | Man‑in‑the‑middle attacks | Pin certificates in production builds |
| Logging sensitive data | Leakage through log files | Never log tokens, passwords, or PII |

### Architecture
| Bad practice | Problem | Correct approach |
|---|---|---|
| Business logic inside UI components | Untestable, hard to maintain | Separate service / repository layer |
| Global state for everything | Unnecessary re‑renders, complexity | Prefer local state; lift only when shared |
| Deep linking added after launch | Broken navigation from notifications or shares | Design deep‑link schema from day one |
| Forgetting cleanup on unmount | Memory leaks, zombie listeners | Dispose subscriptions, timers, and listeners |

---

## Decision Tree (Framework & Platform)
```
What are you building?
│
├─ Need OTA updates + web team collaboration → React Native + Expo
│
├─ Need pixel‑perfect UI & highest performance → Flutter
│
├─ Target a single native platform →
│   ├─ iOS only → SwiftUI
│   └─ Android only → Kotlin + Jetpack Compose
│
├─ Existing RN codebase, add features → React Native (bare workflow)
│
└─ Existing Flutter codebase, enterprise scale → Flutter
```

---

## Checklist
### Pre‑development
- [ ] Platform(s) confirmed (iOS, Android, or both).
- [ ] Framework selected (React Native, Flutter, SwiftUI, Compose).
- [ ] Navigation pattern chosen (tab, stack, drawer).
- [ ] State‑management approach defined (Zustand, Redux, Riverpod, BLoC, etc.).
- [ ] Offline requirements documented.
- [ ] Deep‑link schema planned.
- [ ] Target devices listed (phone, tablet, both).

### Per screen
- [ ] All touch targets ≥ 44 pt / 48 dp.
- [ ] Primary CTA placed in thumb zone.
- [ ] Loading indicator present for async actions.
- [ ] Error UI with retry option.
- [ ] Offline fallback or cached data displayed.
- [ ] Platform‑specific UI conventions respected.
- [ ] Accessibility labels added.

### Before release
- [ ] Remove all `console.log` / debug statements.
- [ ] Store tokens in SecureStore / Keychain / EncryptedSharedPreferences.
- [ ] Enable SSL pinning for production network calls.
- [ ] Verify list components use virtualization and memoization.
- [ ] Ensure all listeners, timers, and subscriptions are disposed.
- [ ] Test on low‑end devices and under poor network conditions.
- [ ] Verify dark‑mode and OLED battery optimizations.
- [ ] Run accessibility audit (TalkBack, VoiceOver).

---

## Quick Reference Summary
- **Touch target**: ≥ 44 pt (iOS) / 48 dp (Android).
- **Spacing**: ≥ 8 px between interactive elements.
- **List rendering**: FlatList / FlashList (RN) or ListView.builder (Flutter) with memoization.
- **Animations**: Use native driver; animate only `transform` and `opacity`.
- **Security**: SecureStore/Keychain, SSL pinning, no hard‑coded keys.
- **Platform divergence**: Follow native navigation gestures, icon sets, and UI components.
- **Accessibility**: Labels, dynamic type, sufficient contrast.

Follow this guide to create fast, reliable, and platform‑consistent mobile experiences.

## Related skills

Load these when the task spans more than this skill.

- [`design`](../SKILL.md) — Unified parent design skill covering the full lifecycle from brief inference to production. Load first for the shared workflow, then return here for mobile-specific rules.
- [`flutter`](../../flutter/SKILL.md) — Provides expert guidance for building high‑performance, multi‑platform Flutter apps with Dart 3. Use it for ar…
- [`ux-research`](../../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
