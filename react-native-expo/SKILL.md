---
name: react-native-expo
description: "Provides production-ready patterns for building React Native apps with Expo covering architecture, React Navigation, Redux Toolkit or Zustand state management, native modules, offline-first data with SQLite or AsyncStorage, performance profiling with Flipper and Hermes, and EAS Build workflows for App Store, Play Store, and CodePush over-the-air updates. Use when scaffolding expo init, configuring app.json or eas.json, implementing React Navigation stack or tab navigators, writing Redux Toolkit slices or Zustand stores, accessing Camera Location Notifications or SecureStore APIs, setting up WatermelonDB or Realm for offline sync, optimizing bundle size with Metro and Hermes, running eas build --platform ios android, submitting with eas submit, or publishing OTA updates via eas update --branch production."
---

# React Native with Expo – Architecture & Deployment

Use this skill to set up a scalable, offline‑first React Native project with Expo and to publish the app to iOS/Android stores or via OTA updates.

---

## When to use
- Starting a new Expo project or refactoring an existing one.
- Need a clear folder layout, navigation, and state‑management pattern.
- Integrating native Expo modules or custom native code.
- Building an offline‑first mobile app.
- Optimising performance for production.
- Publishing the app to the App Store, Google Play, or delivering OTA updates.

---

## Project Structure
```
my-app/
├─ src/
│  ├─ components/      # reusable UI components
│  ├─ screens/         # screen components (one per route)
│  ├─ navigation/      # React Navigation setup
│  ├─ store/            # Redux Toolkit or Zustand store
│  ├─ services/        # API clients, auth, etc.
│  ├─ utils/           # helpers, constants
│  └─ assets/          # images, fonts, icons
├─ App.tsx
├─ app.json / app.config.js
└─ eas.json            # EAS build profiles
```
Keep code isolated to these directories to simplify testing and CI.

---

## Navigation (React Navigation)
```tsx
// src/navigation/AppNavigator.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import HomeScreen from '../screens/HomeScreen';
import SettingsScreen from '../screens/SettingsScreen';

const Stack = createStackNavigator();

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home" screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Settings" component={SettingsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```
- Use a **stack** for deep navigation, **bottom‑tab** for primary sections, and **drawer** for secondary screens.
- Lazy‑load screens with `React.lazy` and `Suspense` to reduce initial bundle size.

---

## State Management
### Redux Toolkit (recommended for large apps)
```ts
// src/store/store.ts
import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import todoReducer from './slices/todoSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    todo: todoReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```
- Keep slices small and colocated with related UI.
- Use `createAsyncThunk` for API calls; enable automatic caching with `rtk-query` if needed.

### Zustand (lightweight alternative)
```ts
import create from 'zustand';

export const useAuthStore = create(set => ({
  token: null,
  setToken: (t: string) => set({ token: t }),
}));
```
Choose the library that matches app complexity.

---

## Native Modules & Expo APIs
- Prefer **Expo modules** (`expo-constants`, `expo-notifications`, `expo-location`, etc.) – no manual linking required.
- For custom native code, add the package to `plugins` in `app.json` and run `eas build` (Expo handles the native build step).
- Example: using `expo-notifications` for push notifications.
```ts
import * as Notifications from 'expo-notifications';

export async function registerForPush() {
  const { status } = await Notifications.requestPermissionsAsync();
  if (status !== 'granted') return;
  const token = await Notifications.getExpoPushTokenAsync();
  // send token to backend
}
```

---

## Offline‑First Data Layer
- Store critical data in **AsyncStorage** or **expo‑sqlite**.
- Use **React Query** with persistence to sync when network returns.
```ts
import { useQuery, useMutation, QueryClient } from '@tanstack/react-query';
import AsyncStorage from '@react-native-async-storage/async-storage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { cacheTime: 1000 * 60 * 60 * 24 },
  },
});

// Persist cache on app close
queryClient.persistQueryClient({ storage: AsyncStorage });
```
- Mark data as stale only after successful server sync.

---

## Performance Optimisations
- Enable **Hermes** in `android/app/build.gradle` and `ios/Podfile` (`expo-modules-autolinking`).
- Use `React.memo`, `useCallback`, and `useMemo` to avoid unnecessary re‑renders.
- Split large screens with `React.lazy` and `Suspense`.
- Run `npx expo-optimize` to compress images.
- Monitor FPS with **expo‑performance** or **Flipper**.

---

## CI/CD & Build Configuration (EAS)
1. Install EAS CLI globally:
   ```bash
   npm install -g eas-cli
   ```
2. Initialise EAS in the project root:
   ```bash
   eas init
   ```
   This creates `eas.json` with `development`, `preview`, and `production` profiles.
3. Add a **runtimeVersion** to `app.json` (required for OTA updates):
   ```json
   {
     "expo": {
       "runtimeVersion": { "policy": "appVersion" }
     }
   }
   ```
4. Configure environment variables in the Expo dashboard or via `eas secret:create`.
5. Set up a GitHub Actions workflow (example snippet):
   ```yaml
   name: Build & Deploy
   on:
     push:
       branches: [main]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Install Node
           uses: actions/setup-node@v3
           with:
             node-version: 20
         - run: npm ci
         - run: eas build --platform all --profile production --non-interactive
         - name: Submit to stores
           run: |
             eas submit --platform ios --latest
             eas submit --platform android --latest
   ```

---

## Deployment Workflow
### 1. Pre‑Deployment
- ✅ All unit, integration, and e2e tests pass.
- ✅ Increment `version` (human) and `android.versionCode` / `ios.buildNumber` (numeric) in `app.json`.
- ✅ Verify production environment variables are set.
- ✅ Run `npx expo-optimize` and check bundle size (`expo export --output-dir dist`).
- ✅ Test a production build on a physical device:
  ```bash
  eas build --platform ios --profile preview
  eas build --platform android --profile preview
  ```

### 2. App Store Submission
1. Build production binaries:
   ```bash
   eas build --platform ios --profile production
   eas build --platform android --profile production
   ```
2. Download the `.ipa` / `.aab` from the Expo dashboard.
3. Submit with EAS:
   ```bash
   eas submit --platform ios --latest
   eas submit --platform android --latest
   ```
4. Fill in store metadata (screenshots, description, privacy policy).
5. Respond to any review feedback.

### 3. OTA Updates
1. Create or select a release channel (e.g., `production` or `staging`).
2. Publish the update:
   ```bash
   eas update --channel production
   ```
3. Choose a rollout strategy in the Expo dashboard (percentage of users).
4. Monitor adoption via the dashboard or analytics.
5. If a critical bug appears, roll back:
   ```bash
   eas update:rollback --channel production
   ```

---

## Common Pitfalls & How to Avoid Them
| Pitfall | Impact | Fix |
|---|---|---|
| Missing `runtimeVersion` | OTA updates fail on older binaries. | Set `runtimeVersion` in `app.json` and keep it in sync with app version. |
| Large assets not optimized | Increased bundle size, slower startup. | Run `npx expo-optimize` and use vector assets when possible. |
| Using debug builds for store submission | Rejected by Apple/Google. | Always build with `--profile production`. |
| Inconsistent version codes (`android.versionCode` vs `ios.buildNumber`) | Store rejects upload. | Increment both numeric codes whenever you change the public version. |
| Not testing on real devices | Hidden native bugs appear after release. | Install the production build on at least one iOS and one Android device before submission. |

---

## Checklist
- [ ] Define folder layout as shown above.
- [ ] Implement navigation with lazy‑loaded screens.
- [ ] Choose and configure a state‑management library.
- [ ] Add required Expo modules (notifications, location, etc.).
- [ ] Implement offline storage and sync logic.
- [ ] Enable Hermes and run performance linting.
- [ ] Set `runtimeVersion` and version numbers.
- [ ] Run `npx expo-optimize` and verify bundle size < 30 MB.
- [ ] Build preview binaries and test on physical devices.
- [ ] Build production binaries with `eas build --profile production`.
- [ ] Submit binaries to App Store Connect and Google Play.
- [ ] Publish OTA update to the `production` channel.
- [ ] Monitor analytics and crash reports after release.

---

## Resources
- Expo Documentation: https://docs.expo.dev/
- React Navigation: https://reactnavigation.org/
- Redux Toolkit: https://redux-toolkit.js.org/
- EAS Build & Submit: https://docs.expo.dev/eas/
- React Query Persistence: https://tanstack.com/query/v4/docs/react/guides/persisting-cache

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`react-state-management`](../react-state-management/SKILL.md) — A concise guide for choosing and implementing React state management solutions—Redux Toolkit, Zustand, Jotai,…
- [`mobile-design`](../mobile-design/SKILL.md) — Guidelines for mobile‑first design of iOS, Android, and cross‑platform apps. Covers touch targets, performance…
- [`firebase-backend`](../firebase-backend/SKILL.md) — Expert guidance for building scalable, secure backends using Firebase. Use this skill for tasks involving Fire…
- [`app-store-optimization`](../app-store-optimization/SKILL.md) — Provides end‑to‑end guidance for researching keywords, optimizing metadata, managing reviews, planning launche…
