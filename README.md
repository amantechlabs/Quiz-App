# QuizMaster Pro

A production-ready, fully offline Flutter quiz app built for the University of Delhi
APP Development using Flutter course (NEP UGCF 2022).

---

## Features

- 9 subjects × 500 questions = **4,500 questions** total
- **Multiple local profiles** on the same device
- **15-session history** per profile with detailed breakdown
- **Timer mode** (15s per question) or untimed
- **Easy / Medium / Hard** difficulty selection
- **Score tracking**, per-subject accuracy charts
- **9 achievement badges** auto-unlocked on milestones
- **Review wrong answers** after every quiz
- **100% offline** — no internet required
- Dark theme throughout

---

## Subjects

| Subject | Easy | Medium | Hard |
|---|---|---|---|
| Geography | 200 | 150 | 150 |
| History | 200 | 150 | 150 |
| Political Science | 200 | 150 | 150 |
| Physics | 200 | 150 | 150 |
| Biology | 200 | 150 | 150 |
| Chemistry | 200 | 150 | 150 |
| Mathematics | 200 | 150 | 150 |
| General Knowledge | 200 | 150 | 150 |
| General Science | 200 | 150 | 150 |

---

## Setup Instructions

### 1. Create a new Flutter project

```bash
flutter create quizmaster_pro
cd quizmaster_pro
```

### 2. Replace the contents

Copy all files from this zip into the project folder, replacing existing ones:

- Replace `lib/` entirely
- Replace `pubspec.yaml`
- Copy `assets/` folder into the project root

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

> **First launch**: The app will seed all 4,500 questions into SQLite on first run.
> This takes 3–10 seconds and shows a progress bar on the splash screen.
> All subsequent launches are instant.

---

## Project Structure

```
lib/
├── main.dart
├── models/          # Question, Profile, Session, SessionAnswer, Achievement
├── database/        # DbHelper, DAOs (Profile, Question, Session, Achievement), Seeder
├── providers/       # ProfileProvider, QuizProvider, HistoryProvider
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/  # ProfileSetupScreen
│   ├── home/        # HomeScreen, ProfileSwitcherSheet
│   ├── quiz/        # QuizConfigScreen, QuizScreen, ReviewScreen
│   ├── result/      # ResultScreen
│   ├── history/     # HistoryScreen, SessionDetailScreen
│   ├── stats/       # StatsScreen
│   ├── achievements/# AchievementsScreen
│   └── settings/    # SettingsScreen
├── utils/           # AppTheme, AchievementEngine
assets/
└── data/
    └── questions.json   ← 4,500 questions
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `sqflite` | Local SQLite database |
| `path` | Database file path resolution |
| `shared_preferences` | Store active profile ID + seed flag |
| `google_fonts` | Poppins typography |

---

## Achievements

| Badge | Condition |
|---|---|
| 🎯 First Quiz | Complete any quiz |
| 💯 Perfect Score | 100% on any quiz |
| 🔥 On Fire | 5 correct answers in a row |
| 📚 Scholar | Play all 9 subjects |
| 🧠 Genius | 90%+ on Hard difficulty |
| 🏃 Speed Demon | Avg < 8s/question in timed mode |
| 📅 Consistent | 5 sessions in the same subject |
| 🌍 Explorer | Play all 9 subjects at least once |
| ⚡ Hard Mode Hero | 3 consecutive Hard sessions with 80%+ |
