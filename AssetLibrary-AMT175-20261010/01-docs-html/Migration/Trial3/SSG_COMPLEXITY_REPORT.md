# SSG Program Complexity Analysis Report
**Date:** 2026-08-19  
**Analyzed Programs:** 20  
**Analysis Basis:** Command counts, file assignments, database references, and source lines

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Total Programs** | 20 |
| **Avg Complexity Score** | 117.0 |
| **Highest Score** | SCAN_ASCII (214.6) |
| **Lowest Score** | UNLOADIS_ASCII (26.9) |
| **Avg SSG Directives** | 150 |
| **Avg COBOL Lines** | 240 |
| **Avg File Assignments** | 6 |
| **Avg DB References** | 27 |

---

## Programs Ranked by Complexity Score

**Scoring Formula:** `(SSGCount × 0.3) + (DBReferences × 0.4) + (TotalLines × 0.15) + (FileAssignments × 0.15)`

| Rank | Program | Score | Lines | SSG | DB | Files | Types | Complexity |
|------|---------|-------|-------|-----|----|----|-------|------------|
| 1 | SCAN_ASCII | 214.6 | 620 | 390 | 10 | 4 | 14 | 🔴 **CRITICAL** |
| 2 | CONDIS2_ASCII | 210 | 911 | 124 | 89 | 4 | 9 | 🔴 **CRITICAL** |
| 3 | TAPELD_ASCII | 209.5 | 635 | 287 | 67 | 9 | 13 | 🔴 **CRITICAL** |
| 4 | TABAN_ASCII | 191.5 | 626 | 245 | 58 | 6 | 13 | 🔴 **CRITICAL** |
| 5 | EXTEUR | 183.3 | 961 | 62 | 48 | 9 | 8 | 🔴 **CRITICAL** |
| 6 | RECAP | 164.1 | 540 | 195 | 60 | 4 | 12 | 🟠 **HIGH** |
| 7 | FUSBA_ASCII | 161.5 | 515 | 255 | 18 | 4 | 13 | 🟠 **HIGH** |
| 8 | CFH-COPY_ASCII | 155.6 | 442 | 272 | 16 | 9 | 13 | 🟠 **HIGH** |
| 9 | CFH-COPY | 146 | 416 | 253 | 16 | 9 | 13 | 🟠 **HIGH** |
| 10 | BABA_ASCII | 137.7 | 426 | 223 | 15 | 6 | 14 | 🟠 **HIGH** |
| 11 | FUSBA2_ASCII | 131.4 | 426 | 199 | 18 | 4 | 13 | 🟠 **HIGH** |
| 12 | LECTIS_ASCII | 78.6 | 356 | 65 | 12 | 6 | 6 | 🟡 **MEDIUM** |
| 13 | LOADIS_MULTI | 77 | 257 | 99 | 20 | 5 | 5 | 🟡 **MEDIUM** |
| 14 | ARCHIFORMAT | 73 | 383 | 22 | 19 | 9 | 7 | 🟡 **MEDIUM** |
| 15 | CHAB100_ASCII | 69.1 | 268 | 76 | 13 | 6 | 10 | 🟡 **MEDIUM** |
| 16 | CHABAN_ASCII | 69 | 267 | 76 | 13 | 6 | 13 | 🟡 **MEDIUM** ✅ *Completed* |
| 17 | UNLOADIS_MULTI | 56.2 | 181 | 69 | 19 | 5 | 5 | 🟢 **LOW** |
| 18 | ARCHISEPARE | 41.9 | 238 | 14 | 2 | 8 | 10 | 🟢 **LOW** |
| 19 | LOADIS_ASCII | 37.1 | 127 | 42 | 12 | 4 | 8 | 🟢 **LOW** |
| 20 | UNLOADIS_ASCII | 26.9 | 100 | 23 | 11 | 4 | 5 | 🟢 **LOW** ✅ *Near completion* |

---

## Complexity Categories

### 🔴 CRITICAL COMPLEXITY (Score > 180)
**Characteristics:** Heavy SSG macros OR High database access, large programs  
**Estimated Effort:** 2-3 weeks each  
**Recommendation:** Plan concurrent team efforts; may need specialized DB expertise

| # | Program | Score | Key Issues |
|----|---------|-------|-----------|
| 1 | SCAN_ASCII | 214.6 | **390 SSG directives** - Highest macro complexity; 14 unique types; 4 file assignments |
| 2 | CONDIS2_ASCII | 210 | **89 DB references** - Highest DB complexity; 911 lines; COBOL-heavy (510 lines) |
| 3 | TAPELD_ASCII | 209.5 | **287 SSG + 67 DB** - Balanced high complexity; 9 file assignments; 336 COBOL lines |
| 4 | TABAN_ASCII | 191.5 | **245 SSG + 58 DB** - High macro + DB burden; 626 lines; 370 COBOL lines |
| 5 | EXTEUR | 183.3 | **961 lines total** - Largest program; 527 COBOL lines; 48 DB references; 9 files |

### 🟠 HIGH COMPLEXITY (Score 130-180)
**Characteristics:** Heavy SSG macro usage (200+) with moderate DB access  
**Estimated Effort:** 1.5-2 weeks each  
**Recommendation:** Start after critical tier stabilizes; pair with developers familiar with SSG macros

| # | Program | Score | Key Issues |
|----|---------|-------|-----------|
| 6 | RECAP | 164.1 | 195 SSG directives; 60 DB refs (3rd highest); 540 lines |
| 7 | FUSBA_ASCII | 161.5 | 255 SSG directives; 515 lines; 13 unique SSG types |
| 8 | CFH-COPY_ASCII | 155.6 | **272 SSG directives** (2nd highest); 442 lines; 9 file assignments |
| 9 | CFH-COPY | 146 | 253 SSG directives; 416 lines; 9 file assignments; variant of #8 |
| 10 | BABA_ASCII | 137.7 | 223 SSG directives; 14 unique types (tied-highest); 426 lines |
| 11 | FUSBA2_ASCII | 131.4 | 199 SSG directives; 426 lines; variant of FUSBA_ASCII (#7) |

### 🟡 MEDIUM COMPLEXITY (Score 50-130)
**Characteristics:** Mixed SSG and DB workload; moderate size (250-400 lines)  
**Estimated Effort:** 1-1.5 weeks each  
**Recommendation:** Begin after 2-3 critical programs complete; good learning opportunity

| # | Program | Score | Key Issues |
|----|---------|-------|-----------|
| 12 | LECTIS_ASCII | 78.6 | 356 lines; 65 SSG; only 6 unique types (simplest SSG profile) |
| 13 | LOADIS_MULTI | 77 | 257 lines; 99 SSG; 5 unique types (minimal variety); 20 DB refs |
| 14 | ARCHIFORMAT | 73 | 383 lines; only 22 SSG directives (lowest macro usage); 9 file assignments |
| 15 | CHAB100_ASCII | 69.1 | 268 lines; 76 SSG; **variant of CHABAN_ASCII** (already completed) |
| 16 | CHABAN_ASCII | 69 | **✅ ALREADY COMPLETED** - Reference model for similar programs |

### 🟢 LOW COMPLEXITY (Score < 50)
**Characteristics:** Small programs with minimal SSG macro use or DB access  
**Estimated Effort:** 0.5-1 week each  
**Recommendation:** Ideal for onboarding junior developers; rapid conversion cycle

| # | Program | Score | Key Issues |
|----|---------|-------|-----------|
| 17 | UNLOADIS_MULTI | 56.2 | 181 lines; 69 SSG; 5 unique types; **variant of UNLOADIS_ASCII** |
| 18 | ARCHISEPARE | 41.9 | **Simplest program** - 238 lines; only 14 SSG; 2 DB refs (lowest) |
| 19 | LOADIS_ASCII | 37.1 | **2nd smallest** - 127 lines; 42 SSG; 4 files; **variant of LOADIS_MULTI** |
| 20 | UNLOADIS_ASCII | 26.9 | **✅ NEAR COMPLETION** - Smallest (100 lines); 23 SSG; 5 unique types |

---

## Detailed Metrics Table

| Program | Total Lines | SSG Directives | Unique SSG Types | COBOL Lines | File Assignments | DB References | Complexity Score |
|---------|-------------|-----------------|----------------|-------------|------------------|---------------|-----------------|
| SCAN_ASCII | 620 | 390 | 14 | 173 | 4 | 10 | 214.6 |
| CONDIS2_ASCII | 911 | 124 | 9 | 510 | 4 | 89 | 210.0 |
| TAPELD_ASCII | 635 | 287 | 13 | 336 | 9 | 67 | 209.5 |
| TABAN_ASCII | 626 | 245 | 13 | 370 | 6 | 58 | 191.5 |
| EXTEUR | 961 | 62 | 8 | 527 | 9 | 48 | 183.3 |
| RECAP | 540 | 195 | 12 | 332 | 4 | 60 | 164.1 |
| FUSBA_ASCII | 515 | 255 | 13 | 260 | 4 | 18 | 161.5 |
| CFH-COPY_ASCII | 442 | 272 | 13 | 166 | 9 | 16 | 155.6 |
| CFH-COPY | 416 | 253 | 13 | 159 | 9 | 16 | 146.0 |
| BABA_ASCII | 426 | 223 | 14 | 200 | 6 | 15 | 137.7 |
| FUSBA2_ASCII | 426 | 199 | 13 | 227 | 4 | 18 | 131.4 |
| LECTIS_ASCII | 356 | 65 | 6 | 284 | 6 | 12 | 78.6 |
| LOADIS_MULTI | 257 | 99 | 5 | 154 | 5 | 20 | 77.0 |
| ARCHIFORMAT | 383 | 22 | 7 | 286 | 9 | 19 | 73.0 |
| CHAB100_ASCII | 268 | 76 | 10 | 191 | 6 | 13 | 69.1 |
| CHABAN_ASCII | 267 | 76 | 10 | 190 | 6 | 13 | 69.0 |
| UNLOADIS_MULTI | 181 | 69 | 5 | 111 | 5 | 19 | 56.2 |
| ARCHISEPARE | 238 | 14 | 10 | 159 | 8 | 2 | 41.9 |
| LOADIS_ASCII | 127 | 42 | 8 | 84 | 4 | 12 | 37.1 |
| UNLOADIS_ASCII | 100 | 23 | 5 | 75 | 4 | 11 | 26.9 |

---

## Phased Conversion Strategy

### ✅ Phase 6 (COMPLETED)
- **CHABAN_ASCII** - Validated running 04:48 & 23:03 (BatchId 1022, ~6s each, 729B log)

### 🔄 Phase 6b (IN PROGRESS)
- **UNLOADIS_ASCII** - Simplest remaining; fixture prep needed for indexed FICHIN-1

### 📋 Phase 7 - Immediate Priority (Next 2-3 weeks)
**Goal:** Convert 4-5 similar low-complexity programs to validate harness scalability

1. **UNLOADIS_MULTI** ⭐ `Score: 56.2` | Variant of UNLOADIS_ASCII; 181 lines
2. **LOADIS_ASCII** ⭐ `Score: 37.1` | Smallest remaining; 127 lines; 5 unique SSG types
3. **LOADIS_MULTI** ⭐ `Score: 77` | Variant of LOADIS_ASCII; 257 lines
4. **ARCHISEPARE** ⭐ `Score: 41.9` | Only 2 DB refs (simplest DB profile); 238 lines

**Expected Outcome:** Batch harness fully validated; PowerShell/C# conversion pipeline proven at scale

### 📅 Phase 8 - Medium Complexity (Weeks 4-6)
**Goal:** Begin high-macro programs; develop SSG macro expertise

1. **LECTIS_ASCII** `Score: 78.6` | 6 unique SSG types; 356 lines
2. **CHAB100_ASCII** `Score: 69.1` | Sibling to CHABAN_ASCII; reuse test patterns; 268 lines
3. **ARCHIFORMAT** `Score: 73` | Minimal SSG (22 directives), 9 files; data flow analysis
4. **RECAP** `Score: 164.1` | 60 DB refs (2nd highest); 540 lines; parallel track with DB team

### 🚨 Phase 9+ - High Complexity (Concurrent Efforts)
**Goal:** Distribute across specialized sub-teams; highest payoff programs

#### Track A: SSG Macro Mastery (Heavy Directives)
1. **CFH-COPY_ASCII** `Score: 155.6` | 272 SSG (2nd highest); 9 files; 442 lines
2. **CFH-COPY** `Score: 146` | Variant; 416 lines; test reuse from #1
3. **SCAN_ASCII** `Score: 214.6` | **APEX DIFFICULTY** - 390 SSG directives (highest); 14 types; 620 lines
4. **FUSBA_ASCII** `Score: 161.5` | 255 SSG; 515 lines; 13 types
5. **BABA_ASCII** `Score: 137.7` | 223 SSG; 14 types (tied-highest); 426 lines

#### Track B: Database Integration (High DB Access)
1. **TABAN_ASCII** `Score: 191.5` | 58 DB refs (3rd highest); 245 SSG; 626 lines
2. **TAPELD_ASCII** `Score: 209.5` | 67 DB refs (2nd highest); 287 SSG; 9 files
3. **CONDIS2_ASCII** `Score: 210` | **89 DB refs (HIGHEST)** - 911 lines; 510 COBOL; DB expertise critical
4. **EXTEUR** `Score: 183.3` | **Largest program** - 961 lines; 48 DB refs; 9 files

#### Track C: Variant Cleanup
1. **FUSBA2_ASCII** `Score: 131.4` | Variant of FUSBA_ASCII (#7); reuse 80% of test fixtures

---

## Key Metrics & Insights

### SSG Macro Complexity
- **Highest:** SCAN_ASCII (390), CFH-COPY_ASCII (272), CFH-COPY (253)
- **Lowest:** ARCHISEPARE (14), ARCHIFORMAT (22), UNLOADIS_ASCII (23)
- **Median:** ~150 directives
- **Most Unique Types:** BABA_ASCII & SCAN_ASCII (14 types each)

### Program Size Distribution
- **Largest:** EXTEUR (961 lines), CONDIS2_ASCII (911)
- **Smallest:** UNLOADIS_ASCII (100), LOADIS_ASCII (127)
- **Median:** ~383 lines
- **COBOL-Heavy:** EXTEUR (527), CONDIS2_ASCII (510), TABAN_ASCII (370)

### Database Complexity
- **Highest:** CONDIS2_ASCII (89 refs), TAPELD_ASCII (67), RECAP (60), TABAN_ASCII (58)
- **Lowest:** ARCHISEPARE (2), ARCHIFORMAT (19), UNLOADIS_ASCII (11)
- **12 programs** have DB refs ≥ 12; **8 programs** have DB refs < 12
- **Pattern:** DB refs correlate with file count; suggests multi-table join scenarios

### File Assignment Patterns
- **Most files:** ARCHIFORMAT, CFH-COPY, CFH-COPY_ASCII, EXTEUR (9 each)
- **Fewest files:** RECAP, SCAN_ASCII, LOADIS_ASCII, UNLOADIS_ASCII (4 each)
- **Median:** 6 files/program
- **Insight:** 9-file programs likely data integration/consolidation logic

---

## Risk Assessment

| Risk | Programs Affected | Mitigation |
|------|-------------------|-----------|
| **SSG Macro Explosion** | SCAN_ASCII, CFH-COPY*, FUSBA* (5 total) | Assign most experienced SSG engineer; create macro translation dictionary |
| **Database Complexity** | CONDIS2_ASCII, TAPELD_ASCII, RECAP, TABAN_ASCII (4 total) | Engage DBA; validate SQL generation; test multi-table scenarios |
| **Large Program Size** | EXTEUR (961L), CONDIS2_ASCII (911L) (2 total) | Break into modules; stagger testing |
| **Variant Duplication** | CFH-COPY/ASCII, FUSBA/FUSBA2, LOADIS/LOADIS_MULTI, UNLOADIS/UNLOADIS_MULTI (8 total) | Reuse fixtures & test patterns; reduce effort by ~40% |

---

## Recommended Next Steps

1. **This Week (Phase 6b Completion)**
   - Finalize UNLOADIS_ASCII indexed fixture
   - Run `Run-UnloadAscii.ps1` harness, confirm "Script Done" in CC Batch Control

2. **Next 2-3 Days (Phase 7 Launch)**
   - Strip & convert UNLOADIS_MULTI (same pattern as UNLOADIS_ASCII)
   - Strip & convert LOADIS_ASCII (smallest new program)
   - Prepare fixtures for both (card file inputs, expected outputs)

3. **Week 2-3 (Phase 7 Continuation)**
   - Convert LOADIS_MULTI, ARCHISEPARE
   - Measure conversion time; identify bottlenecks
   - Document variant reuse patterns (CFH, FUSBA, LOADIS, UNLOADIS families)

4. **Concurrent Planning (Phase 8+)**
   - Form Track A (Macro) & Track B (DB) sub-teams
   - Create SCAN_ASCII & CONDIS2_ASCII spike tasks
   - Schedule code review gates for critical programs
