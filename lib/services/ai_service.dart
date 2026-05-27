import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

abstract interface class IAIService {
  Future<GameEvent?> generateNextEvent(
    PlayerStats stats,
    String previousOutcome,
    List<Decision> recentDecisions, {
    String? themePack,
  });

  Future<LifeStoryResult> generateLifeStory(
    PlayerStats stats,
    List<String> lifeLog,
    List<Decision> decisions,
  );

  Future<String?> generateQuietYear(PlayerStats stats);
}

class AIService implements IAIService {
  static const String _geminiModel = 'gemini-2.5-flash';

  final GenerativeModel _eventModel;
  final GenerativeModel _storyModel;

  final _random = Random();

  AIService({required String apiKey})
      : _eventModel = GenerativeModel(
          model: _geminiModel,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: Schema.object(
              properties: {
                'title': Schema.string(description: 'The title of the event'),
                'description': Schema.string(
                  description: 'The narrative description of the event. Should feel age-appropriate and natural — not necessarily tied to the previous outcome.',
                ),
                'isDefining': Schema.boolean(
                  description: 'Set true ONLY for milestone events that permanently reshape who this person is — founding a company, committing a serious crime, a major public scandal, losing someone irreplaceable, or joining a movement. Approximately once every 10–15 years. Most events should be false.',
                ),
                'options': Schema.array(
                  items: Schema.object(
                    properties: {
                      'text': Schema.string(
                        description: 'An action the PLAYER themselves takes, written in first-person (e.g. "I stay up all night studying", "I sneak out to the party", "I stand up to the bully"). NEVER write actions done by parents, teachers, or other characters — the player is always the one acting.',
                      ),
                      'outcome_description': Schema.string(
                        description: 'A vivid 2-3 sentence narrative describing exactly what happens as a direct result of this choice, and how it changes the character\'s life going forward.',
                      ),
                      'happinessEffect': Schema.integer(
                        description: 'Change to happiness (-30 to 30)',
                      ),
                      'healthEffect': Schema.integer(
                        description: 'Change to health (-30 to 30)',
                      ),
                      'smartsEffect': Schema.integer(
                        description: 'Change to smarts (-30 to 30)',
                      ),
                      'looksEffect': Schema.integer(
                        description: 'Change to looks (-30 to 30)',
                      ),
                      'moralityEffect': Schema.integer(
                        description: 'Change to morality (-30 to 30). Set ONLY for choices with a clear ethical/moral dimension. Default 0.',
                      ),
                      'disciplineEffect': Schema.integer(
                        description: 'Change to discipline (-30 to 30). Set ONLY for choices involving consistency, work ethic, or self-control. Default 0.',
                      ),
                      'popularityEffect': Schema.integer(
                        description: 'Change to popularity (-30 to 30). Set ONLY for choices with meaningful social or public impact. Default 0.',
                      ),
                      'creativityEffect': Schema.integer(
                        description: 'Change to creativity (-30 to 30). Set ONLY for choices involving artistic, unconventional, or imaginative thinking. Default 0.',
                      ),
                      'wealthEffect': Schema.integer(
                        description: 'Change to wealth (-30 to 30). Set ONLY for choices with significant financial consequences. Default 0.',
                      ),
                      'greedEffect': Schema.integer(
                        description: 'Change to greed (-30 to 30). Set ONLY for choices driven by power, money, or accumulation. Default 0.',
                      ),
                      'reputationEffect': Schema.integer(
                        description: 'Change to reputation (-30 to 30). Set ONLY for choices that visibly affect public image. Default 0.',
                      ),
                      'occupationUpdate': Schema.string(
                        description: 'Set this ONLY if the chosen action meaningfully changes the person\'s occupation or role (e.g. "nurse", "unemployed", "CEO of startup"). Leave null if occupation is unchanged.',
                      ),
                      'relationshipUpdate': Schema.string(
                        description: 'Set ONLY if relationship status changes: "single", "in a relationship", "married", "divorced", or "widowed". Leave null if unchanged.',
                      ),
                      'criminalRecordUpdate': Schema.string(
                        description: 'Set ONLY if criminal status changes: "none", "minor offenses", "convicted felon". Leave null if unchanged.',
                      ),
                      'fameLevelUpdate': Schema.string(
                        description: 'Set ONLY if fame changes: "unknown", "local", "regional", "nationally known", "famous". Leave null if unchanged.',
                      ),
                      'majorEventNote': Schema.string(
                        description: 'A short phrase (under 10 words) capturing a defining life moment from this outcome that should be remembered forever, like "lost family savings at age 24" or "published first novel". Only set for truly major, life-defining outcomes — most choices should leave this null.',
                      ),
                      'involvedNPC': Schema.string(
                        description: 'The first name (or name + role) of a specific person who is central to this outcome — a friend, rival, mentor, romantic interest, or stranger who matters. Set this when the outcome features a named individual the player might encounter again. Leave null for outcomes with no specific person involved.',
                      ),
                      'newTension': Schema.string(
                        description: 'A short phrase describing a new unresolved conflict this choice opens — an ongoing debt, rivalry, estrangement, criminal risk, or commitment that will haunt future events. Only set when the choice genuinely opens a lasting conflict thread. Leave null otherwise.',
                      ),
                      'resolvesTension': Schema.boolean(
                        description: 'Set true if this choice definitively closes or resolves one of the player\'s existing unresolved tensions. Only set true when the resolution is meaningful and earned — not just vaguely related. Leave null or false otherwise.',
                      ),
                    },
                    requiredProperties: [
                      'text',
                      'outcome_description',
                      'happinessEffect',
                      'healthEffect',
                      'smartsEffect',
                      'looksEffect',
                    ],
                  ),
                ),
              },
              requiredProperties: ['title', 'description', 'options'],
            ),
          ),
        ),
        _storyModel = GenerativeModel(
          model: _geminiModel,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 1.0,
            responseMimeType: 'application/json',
            responseSchema: Schema.object(
              properties: {
                'headline': Schema.string(
                  description: 'A single punchy newspaper-style headline about this person\'s life — under 15 words. Should be memorable and shareable.',
                ),
                'personalityType': Schema.string(
                  description: 'A 3-5 word personality archetype label for this person, like "The Reluctant Hero", "The Joyful Wanderer", "The Calculating Opportunist", or "The Quiet Saint". Should reflect who they became.',
                ),
                'story': Schema.string(
                  description: 'Exactly 2-3 short paragraphs in third-person, like a brief but moving eulogy. Be concise and emotionally resonant. Every sentence must earn its place. Capture who they were, what shaped them, and the mark they left behind. Do not pad or over-explain.',
                ),
                'worldLost': Schema.string(
                  description: 'A single evocative sentence about what the world lost when this person died. Not sentimental — specific to who they were.',
                ),
              },
              requiredProperties: ['headline', 'personalityType', 'story', 'worldLost'],
            ),
          ),
        );

  static const Map<String, String> _themePrompts = {
    'cyberpunk':
        'This life takes place in a cyberpunk near-future world. All events, careers, and social situations should reflect that setting — megacorporations, neural implants, hacking culture, neon-lit megacities, and the sharp divide between elite and underclass.',
    'medieval':
        'This life takes place in a medieval world. All events should reflect that era — trades and guilds, nobles and serfs, plague and war, arranged marriages, religious institutions, and the brutal uncertainty of life before modernity.',
    'horror':
        'This life takes place in a world tinged with horror. Paranormal elements, cursed decisions, and dark outcomes are present alongside ordinary life events. Not every event needs to be horrific — but dread should linger at the edges.',
    'celebrity':
        'This life takes place in the hyper-visible world of celebrity culture. Events revolve around fame cycles, paparazzi, brand deals, public image management, social media obsession, public scandals, and the cost of living in the spotlight.',
  };

  @override
  Future<GameEvent?> generateNextEvent(
    PlayerStats stats,
    String previousOutcome,
    List<Decision> recentDecisions, {
    String? themePack,
  }) async {
    final decisionContext = recentDecisions.isEmpty
        ? 'No prior decisions yet — this is early in life.'
        : recentDecisions.map((d) => '  • ${d.toString()}').join('\n');

    // 40% of the time, drop the direct previous-outcome context so events feel
    // fresh and independent — life doesn't always follow a direct script.
    final useDirectContext = _random.nextDouble() >= 0.4;
    final contextLine = useDirectContext
        ? 'Recent context (for background only, NOT required to drive the event): "$previousOutcome"'
        : 'No specific recent context — something new is about to happen.';

    final narrativeSummary = _buildNarrativeSummary(stats);

    final npcContext = stats.npcSeeds.isEmpty
        ? ''
        : 'Known people in this person\'s life: ${stats.npcSeeds.join(', ')}. You may reintroduce any of them when it fits naturally — do not force it.\n';

    final tensionsBlock = stats.unresolvedTensions.isEmpty
        ? ''
        : '''
Unresolved Tensions (ongoing conflicts — escalate these when appropriate; do not reset tone):
${stats.unresolvedTensions.map((t) => '  • $t').join('\n')}
''';

    final lifePathBlock = stats.lifePath != null
        ? 'Current Life Path: ${stats.lifePath}. Events should reflect the opportunities and pressures of that life — include elements that only someone on this specific path would face.\n'
        : '';

    final dueCallback = stats.callbacks
        .where((c) => stats.age >= c.callbackAgeMin && stats.age <= c.callbackAgeMax)
        .firstOrNull;
    final callbackBlock = dueCallback == null
        ? ''
        : 'CALLBACK MOMENT: A defining past event from age ${dueCallback.seedAge} is now resurfacing: "${dueCallback.seedDescription}". Weave this naturally into this year\'s event — it should feel like the past catching up. The return type for this callback: ${dueCallback.possibleReturnTypes[_random.nextInt(dueCallback.possibleReturnTypes.length)]}.\n';

    final midLifeCrisisBlock = (stats.age >= 35 && stats.age <= 55)
        ? 'MID-LIFE DISRUPTION WINDOW: This person is between ages 35–55. If no major life disruption has yet occurred (burnout, divorce, scandal, addiction, career collapse, betrayal, health scare, existential crisis, reinvention), now is the time to introduce one. It should feel inevitable given their choices — not random. If a major disruption has already clearly happened, skip this.\n'
        : '';

    final themeBlock = (themePack != null && _themePrompts.containsKey(themePack))
        ? 'THEME: ${_themePrompts[themePack]}\n'
        : '';

    final hiddenStatsBlock = '''
Character Tendencies (internal — use these to shape event tone and option weighting, not to expose as numbers):
- Morality: ${_tendency(stats.morality)} (${stats.morality}/100)
- Discipline: ${_tendency(stats.discipline)} (${stats.discipline}/100)
- Popularity: ${_tendency(stats.popularity)} (${stats.popularity}/100)
- Creativity: ${_tendency(stats.creativity)} (${stats.creativity}/100)
- Wealth: ${_tendency(stats.wealth)} (${stats.wealth}/100)
- Greed: ${_tendency(stats.greed)} (${stats.greed}/100)
- Reputation: ${_tendency(stats.reputation)} (${stats.reputation}/100)
''';

    final prompt = '''
You are the narrator of an immersive life simulator. A year has passed in this person's life.
${themeBlock.isNotEmpty ? '\n$themeBlock' : ''}
Current Stats:
- Happiness: ${stats.happiness}/100
- Health: ${stats.health}/100
- Smarts: ${stats.smarts}/100
- Looks: ${stats.looks}/100
- Age: ${stats.age}

$narrativeSummary

$hiddenStatsBlock$tensionsBlock$lifePathBlock$midLifeCrisisBlock$callbackBlock
$npcContext$contextLine

Recent decisions (background context — do NOT force a direct connection):
$decisionContext

IMPORTANT — VARIETY RULE: Life does not always follow a direct script. Generate an age-appropriate event that feels natural for someone who is ${stats.age} years old. The event can be:
  • Something entirely new and unrelated to recent events (life just happens — a new person appears, a random opportunity, an unexpected situation)
  • A loose, indirect continuation of the current mood
  • A distant echo of an older decision resurfacing years later
Do NOT make every event feel like an immediate consequence of the last choice. Mix it up.

CRITICAL RULE FOR OPTIONS: Every option must be a first-person action the PLAYER themselves takes — never a parent, teacher, or other character. Bad: "My parents sign me up for tutoring." Good: "I ask my teacher for extra help after school." Write 3 options with genuinely different consequences:
  • Each option MUST have at least one real cost or downside — no free wins
  • Create identity dilemmas, not obvious good/bad splits — both the "safe" and "risky" options should have legitimate appeal and legitimate consequences
  • Bittersweet, ironic, and tragic outcomes are strongly preferred over purely positive resolutions
  • Create moments the player will remember or regret — not sanitized life advice
  Each outcome_description must be vivid (2-3 sentences) showing how the choice reshapes life going forward, including what was lost or left behind.

CONSEQUENCE RULE: Do not soften consequences. When a choice is reckless, show the fallout — don't let the player escape cleanly. When a choice is "safe," show the quiet cost of choosing safety over growth. Some choices should close doors permanently. Some good choices should have delayed bad consequences. Some bad choices should have unexpected silver linings. Life is not a reward system.

DEFINING MOMENTS: Approximately once every 10–15 years, generate a milestone event (set isDefining: true on the event) — a decision that permanently changes who this person is. These should feel earned given their choices. Most events must be isDefining: false.

IDENTITY CONTINUITY: The narrative summary above defines who this person IS right now. Never generate events that contradict it — a person with unknown fame is not already famous; a person with no criminal record has no prior convictions. Events must be consistent with this identity.

TENSION TRACKING: If a chosen option genuinely opens a new lasting conflict (a debt owed, a rivalry ignited, a criminal risk taken, an estrangement caused), set newTension to a short phrase describing it. If a chosen option definitively resolves one of the listed unresolved tensions, set resolvesTension to true. Do not use these fields for minor, forgettable consequences — only for conflicts that will meaningfully shape the player's future.

TENSION ESCALATION: When unresolved tensions exist, escalate them when dramatically appropriate rather than resetting tone each year. Life events should build on previous risks and create rising stakes — a debt grows, a rivalry intensifies, an estrangement deepens.

HIDDEN STAT GUIDANCE: For each option, set hidden stat effects only when the choice clearly warrants it — a moral/ethical choice should adjust moralityEffect; a social/reputation-driven choice should adjust popularityEffect or reputationEffect; a financial or power-seeking choice should adjust wealthEffect or greedEffect. Leave unrelated hidden stat fields at 0. Do not assign hidden stat values arbitrarily — most options should only affect 1–2 hidden stats at most.

Return ONLY valid JSON.
''';

    try {
      final response = await _eventModel.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        final Map<String, dynamic> data = jsonDecode(response.text!);
        return GameEvent.fromJson(data);
      }
    } catch (e) {
      debugPrint('AI Generation Error: $e');
    }
    return null;
  }

  @override
  Future<LifeStoryResult> generateLifeStory(
    PlayerStats stats,
    List<String> lifeLog,
    List<Decision> decisions,
  ) async {
    final decisionNarrative = decisions.isEmpty
        ? 'No recorded decisions.'
        : decisions
            .map((d) => '  • Age ${d.age} — faced "${d.eventTitle}". Chose: "${d.choiceText}". What followed: ${d.outcome}')
            .join('\n');

    final lifePathBlock = stats.lifePath != null
        ? 'Life path: ${stats.lifePath}. The ending should reflect that path specifically — the legacy, regret, and memory that only that life produces. Closing theme: "${_pathEndingFlavor(stats.lifePath)}"\n'
        : '';

    final identitySummary = 'Identity at death: ${stats.identityState.occupation}, '
        '${stats.identityState.relationshipStatus}, '
        'criminal record: ${stats.identityState.criminalRecord}, '
        'fame: ${stats.identityState.fameLevel}, '
        'education: ${stats.identityState.education}'
        '${stats.identityState.majorPastEvents.isEmpty ? '' : ', defining moments: ${stats.identityState.majorPastEvents.join('; ')}'}.';

    final prompt = '''
You are a gifted author writing the story of one person's life. Populate the four JSON fields — headline, personalityType, story, and worldLost — as described. Your writing must be DRIVEN by the choices they made — not just a summary of events, but a narrative about how their decisions defined who they became.

Final Stats:
- Age reached: ${stats.age}
- Happiness: ${stats.happiness}/100
- Health: ${stats.health}/100
- Smarts: ${stats.smarts}/100
- Looks: ${stats.looks}/100
- Achievements: ${stats.achievements.isEmpty ? 'None' : stats.achievements.join(', ')}

$lifePathBlock$identitySummary

The decisions that shaped this life (in order):
$decisionNarrative

Do not list events — tell a story.
''';

    try {
      final response = await _storyModel.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        final data = jsonDecode(response.text!) as Map<String, dynamic>;
        return LifeStoryResult(
          headline: data['headline'] as String? ?? '',
          personalityType: data['personalityType'] as String? ?? '',
          story: data['story'] as String? ?? 'Their story was one that could not be put into words.',
          worldLost: data['worldLost'] as String? ?? '',
        );
      }
    } catch (e) {
      debugPrint('Story Generation Error: $e');
    }
    return LifeStoryResult(
      headline: '',
      personalityType: '',
      story: 'Their story was one that could not be put into words.',
      worldLost: '',
    );
  }

  @override
  Future<String?> generateQuietYear(PlayerStats stats) async {
    final prompt = 'Write a single short sentence (under 20 words) describing a quiet, '
        'uneventful year at age ${stats.age} for someone who is ${stats.identityState.occupation}, '
        '${stats.identityState.relationshipStatus}. No drama. No choices. Just time passing. '
        'Return ONLY the sentence.';
    try {
      final response = await _storyModel.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      debugPrint('Quiet Year Generation Error: $e');
    }
    return null;
  }

  String _buildNarrativeSummary(PlayerStats stats) {
    final id = stats.identityState;
    final parts = <String>[];

    final pathClause = stats.lifePath != null ? ' on the path of a ${stats.lifePath}' : '';
    parts.add('${id.occupation.isEmpty ? 'Someone' : id.occupation.replaceFirst(id.occupation[0], id.occupation[0].toUpperCase())}$pathClause at age ${stats.age}');

    if (id.relationshipStatus != 'single') {
      parts.add(id.relationshipStatus);
    }

    if (id.fameLevel != 'unknown') {
      parts.add('${id.fameLevel} fame');
    }

    if (id.criminalRecord != 'none') {
      parts.add('criminal record: ${id.criminalRecord}');
    }

    if (id.education != 'no degree') {
      parts.add(id.education);
    }

    if (id.majorPastEvents.isNotEmpty) {
      final recent = id.majorPastEvents.length > 2
          ? id.majorPastEvents.sublist(id.majorPastEvents.length - 2)
          : id.majorPastEvents;
      parts.add(recent.join('; '));
    }

    if (stats.unresolvedTensions.isNotEmpty) {
      parts.add('facing: ${stats.unresolvedTensions.join(', ')}');
    }

    final tendencyParts = <String>[];
    if (stats.discipline >= 60 || stats.discipline <= 40) {
      tendencyParts.add('discipline is ${_tendency(stats.discipline)}');
    }
    if (stats.morality >= 60 || stats.morality <= 40) {
      tendencyParts.add('morality is ${_tendency(stats.morality)}');
    }
    if (tendencyParts.isNotEmpty) {
      parts.add(tendencyParts.join('; '));
    }

    return '${parts.join(' — ')}.';
  }

  String _tendency(int value) {
    if (value >= 80) return 'very high';
    if (value >= 60) return 'high';
    if (value >= 40) return 'moderate';
    if (value >= 20) return 'low';
    return 'very low';
  }

  String _pathEndingFlavor(String? path) {
    switch (path) {
      case 'Criminal':
        return 'Died in infamy — the city never forgot, and never forgave.';
      case 'Famous Celebrity':
        return 'The world mourned loudly for a week, then moved on.';
      case 'Entrepreneur':
        return 'Built something that outlasted the builder.';
      case 'Lonely Genius':
        return 'Your work was discovered — forty years too late for you to know.';
      case 'Spiritual Monk':
        return 'Passed peacefully, surrounded by those whose lives you changed.';
      case 'Internet Influencer':
        return 'Thirty million followers. No one who truly knew you.';
      case 'Activist / Revolutionary':
        return 'The thing you fought for finally happened — decades after you were gone.';
      case 'Family Patriarch/Matriarch':
        return 'The room was full. Every person there was someone you made.';
      default:
        return '';
    }
  }
}
