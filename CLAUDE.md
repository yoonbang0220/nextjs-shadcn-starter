# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

## 언어 및 커뮤니케이션 규칙

- **기본 응답 언어**: 한국어
- **코드 주석**: 한국어로 작성
- **커밋 메시지**: 한국어로 작성
- **문서화**: 한국어로 작성
- **변수명/함수명**: 영어 (코드 표준 준수)

## 명령어

```bash
npm run dev      # 개발 서버 실행 (Next.js 16 기본 번들러: Turbopack)
npm run build    # 프로덕션 빌드
npm run start    # 프로덕션 서버 실행
npm run lint     # ESLint 실행
npx prettier --write .            # 전체 파일 포맷팅
npx shadcn@latest add <component> # shadcn/ui 컴포넌트 추가
```

테스트 설정 없음 — 필요 시 직접 구성해야 한다.

## 기술 스택

- **Next.js 16** (App Router, Turbopack 기본 활성화, `"use cache"` 지시자)
- **React 19**
- **TypeScript**
- **Tailwind CSS v4** — `tailwind.config.ts` 없음, `app/globals.css`에서 `@theme` 블록으로 토큰 정의
- **shadcn/ui** (`base-nova` 스타일) — **Radix UI가 아닌 `@base-ui/react` 기반 headless 프리미티브**. 컴포넌트 API가 기존 shadcn과 다를 수 있으므로 각 컴포넌트의 실제 props를 반드시 확인할 것.
- **next-themes** — ThemeProvider, `suppressHydrationWarning` 필수
- **sonner** — Toast 알림 (`<Toaster>`는 루트 레이아웃에 이미 포함됨)

## 아키텍처

```
app/                   # 페이지 및 레이아웃 (App Router)
components/
  ui/                  # shadcn/ui 컴포넌트 (직접 수정 최소화)
  common/              # 프로젝트 공통 컴포넌트 (Header, Footer, ThemeProvider, ThemeToggle, NavItem)
hooks/                 # 커스텀 훅
lib/utils.ts           # cn() 유틸리티 (clsx + tailwind-merge)
types/index.ts         # 공통 TypeScript 타입 (User, ApiResponse, PaginatedResponse, ThemeMode)
```

**레이아웃 계층:**
```
RootLayout (ThemeProvider)
  └── Header
  └── <main>
        └── [페이지 콘텐츠]
        └── DashboardLayout (사이드바 + 콘텐츠) ← /dashboard 하위
  └── Footer
  └── Toaster
```

대시보드(`app/dashboard/layout.tsx`)는 루트 레이아웃 안에 중첩된다. Header/Footer는 대시보드에도 그대로 유지되며, DashboardLayout은 사이드바와 콘텐츠 영역만 추가로 정의한다.

**현재 구현된 페이지:**
- `/` — 홈
- `/login`, `/signup` — 인증 페이지
- `/dashboard` — 대시보드 메인

**사이드바에 정의됐지만 아직 미구현인 페이지:** `/dashboard/analytics`, `/dashboard/users`, `/dashboard/posts`, `/dashboard/settings`

## 주요 패턴

**컴포넌트 변형 관리** — `class-variance-authority`(CVA)로 `variant` / `size` prop 처리. `button.tsx` 참고. `@base-ui/react`의 primitive를 감싸는 패턴 사용 (`ButtonPrimitive.Props` 확장).

**사이드바 활성 상태** — `NavItem` 컴포넌트(`components/common/NavItem.tsx`)가 `usePathname()`으로 현재 경로를 감지해 활성 스타일을 자동 적용. 대시보드 사이드바 항목 추가 시 이 컴포넌트 재사용.

**cn() 유틸리티** — 모든 className 병합은 `cn()` 사용 (Tailwind 클래스 충돌 해결).

**클라이언트 컴포넌트** — 브라우저 API나 훅이 필요한 경우에만 `"use client"` 선언 (ThemeToggle, ThemeProvider, `use-media-query.ts` 등).

**서버 함수 캐싱** — 서버 컴포넌트 내 비동기 함수에 `"use cache"` 지시자 사용 가능 (`next.config.ts`에서 `cacheComponents: true` 활성화됨).

**비동기 params** — Next.js 16에서 `params`와 `searchParams`는 `Promise` 타입이므로 반드시 `await` 필요.

**미들웨어** — Next.js 16에서 `middleware.ts`는 여전히 지원되나, `proxy.ts`로 마이그레이션될 수 있음. 새로 작성 시 공식 문서 확인 필요.

## 스타일링

- 색상 토큰은 `app/globals.css`의 CSS 변수(`--background`, `--primary` 등)로 정의, **oklch** 색상 공간 사용
- 다크모드: `.dark` 클래스 전환 방식 (`@custom-variant dark (&:is(.dark *))`)
- 테마 색상 변경 시 `globals.css`의 `:root` / `.dark` 블록 수정
- Prettier + `prettier-plugin-tailwindcss`로 클래스 자동 정렬됨

## 환경 변수

- `.env.local` 파일에 실제 값 설정 (`.env.example` 참고)
- 클라이언트에서 접근 가능한 변수는 반드시 `NEXT_PUBLIC_` 접두사 사용

## 경로 alias

`@/*` → 프로젝트 루트 (`tsconfig.json` 설정)

## Claude Code 통합 환경

이 저장소에는 Claude Code용 보조 자산이 함께 있다.

- `.claude/agents/` — 서브에이전트 정의 (`code-reviewer-kr`, `qa-engineer`, `reverse-planner`)
- `.claude/commands/git/` — `/git:commit`, `/git:explain` 같은 커스텀 슬래시 명령
- `.claude/settings.json` — 프로젝트 공유 Hook 설정 (현재 Bash PreToolUse 테스트 훅 등록됨)
- `.claude/slack-notify.{sh,ps1}` — 권한 요청 / 작업 완료 / 서브에이전트 이벤트를 Slack에 전달하는 cross-platform 스크립트
- `docs/HOOKS_PLANNING.md` — 위 Slack 알림 시스템의 설계/이슈/로드맵 기획서 (변경 시 참조 필수)

`.claude/settings.local.json`은 `.gitignore`에 있다. Claude Code가 자동 추가하는 permission 룰에 webhook URL 같은 민감값이 섞일 수 있어 의도적으로 untrack 처리되어 있다.

## 저장소 내 임시 부산물

- `hook-test.txt` — `.claude/settings.json`의 PreToolUse 훅이 Bash 실행 시마다 한 줄씩 append하는 로그. `.gitignore`에 있어 무방. 정리하고 싶으면 그냥 삭제.
- `roots/test.txt` — Hook 시스템 초기 테스트 중 생성된 실험 파일. 정리 가능.
