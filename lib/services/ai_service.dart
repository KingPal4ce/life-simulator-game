import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

abstract interface class IAIService {
  Future<GameEvent?> generateNextEvent(
    PlayerStats stats,
    String previousOutcome,
    List<Decision> recentDecisions,
  );

  Future<String> generateLifeStory(
    PlayerStats stats,
    List<String> lifeLog,
    List<Decision> decisions,
  );
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
          ),
        );

  @override
  Future<GameEvent?> generateNextEvent(
    PlayerStats stats,
    String previousOutcome,
    List<Decision> recentDecisions,
  ) async {
    final decisionContext = recentDecisions.isEmpty
        ? 'No prior decisions yet — this is early in life.'
        : recentDecisions.map((d) => '  • ${d.toString()}').join('\n');

    // 40% of the time, drop the direct previous-outcome context so events feel
    // fresh and independent — life doesn't always follow a direct script.
    final useDirectContext = _random.nextDouble() >= 0.4;
    final contextLine = useDirectContext
        ? 'Recent context (for background only, NOT required to drive the event): "$previousOutcome"'
        : 'No specific recent context — something new is about to happen.';

    final prompt = '''
You are the narrator of an immersive life simulator. A year has passed in this person's life.

The player is ${stats.age} years old.

Current Stats:
- Happiness: ${stats.happiness}/100
- Health: ${stats.health}/100
- Smarts: ${stats.smarts}/100
- Looks: ${stats.looks}/100

$contextLine

Past decisions (background context — do NOT force a direct connection):
$decisionContext

IMPORTANT — VARIETY RULE: Life does not always follow a direct script. Generate an age-appropriate event that feels natural for someone who is ${stats.age} years old. The event can be:
  • Something entirely new and unrelated to recent events (life just happens — a new person appears, a random opportunity, an unexpected situation)
  • A loose, indirect continuation of the current mood
  • A distant echo of an older decision resurfacing years later
Do NOT make every event feel like an immediate consequence of the last choice. Mix it up.

CRITICAL RULE FOR OPTIONS: Every option must be a first-person action the PLAYER themselves takes — never a parent, teacher, or other character. Bad: "My parents sign me up for tutoring." Good: "I ask my teacher for extra help after school." Write 3 options with meaningfully different consequences (one risky, one safe, one creative/unusual). Each outcome_description must be vivid (2-3 sentences) showing how the choice reshapes life going forward.

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
  Future<String> generateLifeStory(
    PlayerStats stats,
    List<String> lifeLog,
    List<Decision> decisions,
  ) async {
    final decisionNarrative = decisions.isEmpty
        ? 'No recorded decisions.'
        : decisions
            .map((d) => '  • Age ${d.age} — faced "${d.eventTitle}". Chose: "${d.choiceText}". What followed: ${d.outcome}')
            .join('\n');

    final prompt = '''
You are a gifted author writing the story of one person's life. Your story must be DRIVEN by the choices they made — not just a summary of events, but a narrative about how their decisions defined who they became.

Write exactly 2-3 short paragraphs in third-person, like a brief but moving eulogy. Be concise and emotionally resonant — every sentence must earn its place. Capture who they were, what shaped them, and the mark they left behind. End with one reflective sentence about their legacy. Do not pad or over-explain.

Final Stats:
- Age reached: ${stats.age}
- Happiness: ${stats.happiness}/100
- Health: ${stats.health}/100
- Smarts: ${stats.smarts}/100
- Looks: ${stats.looks}/100
- Achievements: ${stats.achievements.isEmpty ? 'None' : stats.achievements.join(', ')}

The decisions that shaped this life (in order):
$decisionNarrative

Write the story now. Do not list events — tell a story.
''';

    try {
      final response = await _storyModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'Their story was one that could not be put into words.';
    } catch (e) {
      debugPrint('Story Generation Error: $e');
      return 'Their story was one that could not be put into words.';
    }
  }
}
