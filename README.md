# OBSIDIAN – Expense Vault (Flutter Web)

A dark, instrument-panel expense tracker. Black metal, brushed-steel card, analogue gauge,
oscilloscope chart. Palette: blues + greens with a mustard-gold accent.

## Signature visuals
- Studio-lit obsidian background (breathing light, vignette, film grain)
- Brushed-metal card with a live specular highlight that follows the cursor / finger, 3D tilt, EMV chip and holo-sticker
- Analogue budget gauge with real tick marks, colour zones and a spring-loaded needle
- Oscilloscope-style cash-flow chart (glowing trace + scanning beam)
- 70-day spending heatmap, LED-style readouts, recessed "engraved" wells
- Combination-dial login that spins and unlocks into the app

## Concepts covered
| Requirement | Where |
|---|---|
| Widgets (Container, Row, Column, Stack, ListView, Wrap, buttons, cards…) | everywhere; `widgets/materials.dart` |
| Responsive UI | `LayoutBuilder` / `MediaQuery`: floating dock (mobile) → metal rail (tablet/desktop), 1-col → 2-col layouts |
| Navigation | named routes `/`, `/home`, `/add` with custom transitions + 4-tab shell |
| Animations | `TweenAnimationBuilder`, `AnimationController`, `CustomPainter`, `AnimatedSwitcher`, spring needle, unlock sequence |
| State management | `Provider` + `ChangeNotifier`, `StatefulWidget`; data saved with `shared_preferences` |
| Themes & custom widgets | `theme.dart`, `Panel`, `Inset`, `GoldButton`, `MetalCard`, `GaugeDial`, `Scope`, `Heatmap` … |
| Forms & validation | Login (name/email), New entry (title/amount), Vault settings (name/budget) |

## Run locally
```bash
flutter create . --platforms=web     # once – generates the web/ folder
flutter pub get
flutter run -d chrome
```

## Publish (anyone, any device)
**GitHub Pages:** push this folder to a repo on `main`, then Settings → Pages → Source: *GitHub Actions*.
The included workflow builds and deploys it → `https://<user>.github.io/<repo>/`.

**Netlify:** `flutter build web --release`, then drag `build/web` onto app.netlify.com/drop.
