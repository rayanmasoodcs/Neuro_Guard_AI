import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/responsive/responsive.dart';
import '../../database/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  final String userId;
  const ChatbotScreen({super.key, required this.userId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Comprehensive knowledge base covering epilepsy education, safety, and app features
  /// All information is educational only - NOT medical advice
  static final Map<String, String> _knowledgeBase = {
    'epilepsy': '''WHAT IS EPILEPSY?

Epilepsy is a neurological disorder characterized by recurrent seizures. Key facts:

📌 Definition:
• A tendency to have spontaneous, recurrent seizures
• The result of abnormal brain electrical activity
• Affects approximately 50 million people worldwide

🧠 How it develops:
• Can start at any age (most common in children and older adults)
• May be caused by brain injury, genetic factors, or unknown causes
• Severity ranges from mild to severe

🎯 Important notes:
• NOT contagious
• NOT a sign of intellectual disability
• CAN be managed with proper treatment
• People with epilepsy can live full, active lives

🏥 NEXT STEPS: A neurologist can properly evaluate your condition. Schedule an appointment with your healthcare provider for proper diagnosis and treatment planning.''',

    'seizure': '''UNDERSTANDING SEIZURES

A seizure is a sudden burst of abnormal brain electrical activity. Here's what you need to know:

⚡ What happens during a seizure:
• Muscles may contract involuntarily
• Consciousness can be affected
• Duration typically ranges from seconds to a few minutes
• May be preceded by an "aura" (warning sign)

🔍 Types of seizures vary widely:
Different seizures affect the brain in different ways. Your neurologist can identify YOUR specific seizure type through testing and observation.

📊 Seizure patterns:
• Some people have one seizure per year
• Others may have multiple per day
• Patterns often become recognizable over time
• Triggers differ from person to person

⚠️ REMEMBER:
• Seizures can be managed with proper medical care
• Many people become seizure-free with treatment
• Always consult your doctor for personalized information
• This information is educational - not a medical diagnosis''',

    'symptoms': '''RECOGNIZING SEIZURE SYMPTOMS

Symptoms vary greatly depending on seizure type and affected brain region:

🟡 Focal Seizure Symptoms (affects one part of brain):
• Tingling or numbness in specific area
• Muscle twitching or jerking on one side
• Emotional changes or fear
• Visual/auditory disturbances
• Loss of awareness (sometimes)

🔴 Generalized Seizure Symptoms (affects entire brain):
• Unconsciousness
• Violent jerking movements (whole body)
• Stiffening of muscles
• Loss of control of bladder/bowel
• Confusion after seizure ends
• Severe fatigue after seizure

⚠️ Warning signs (Aura - may occur before seizure):
• Unusual tastes or smells
• Visual disturbances (flashing lights, blurred vision)
• Feeling of dread or fear
• Numbness or tingling
• Difficulty speaking

🚨 SEEK IMMEDIATE HELP IF:
• Seizure lasts more than 5 minutes
• Multiple seizures occur close together
• Person doesn't regain consciousness
• You're unsure what's happening

👨‍⚕️ Discuss your specific symptoms with your healthcare provider to understand YOUR seizure patterns.''',

    'triggers': '''COMMON SEIZURE TRIGGERS

While triggers vary by individual, many people notice patterns. Understanding YOUR triggers helps with prevention:

😴 Sleep-Related:
• Sleep deprivation (most common)
• Irregular sleep schedule
• Sleep disorders like sleep apnea
• Poor sleep quality
ACTION: Maintain consistent sleep schedule (7-9 hours nightly)

😰 Stress & Emotions:
• Emotional stress
• Anxiety
• Excitement (even positive!)
• Hormone fluctuations (menstrual cycle)
ACTION: Practice stress management, meditation, or relaxation techniques

💡 Environmental:
• Flashing lights
• Certain patterns (stripes)
• Strong sunlight reflections
• Loud or sudden noises
ACTION: Avoid known triggers when possible; wear sunglasses if needed

🏥 Health Factors:
• Fever or illness
• Low blood sugar
• Dehydration
• Missed medications
• Hormonal changes
ACTION: Stay hydrated, eat regular meals, take medication consistently

🍷 Lifestyle:
• Alcohol consumption
• Excessive caffeine
• Certain recreational drugs
• Fatigue
ACTION: Moderate consumption, adequate rest, healthy habits

⚠️ IMPORTANT:
• Triggers are DIFFERENT for every person
• Keep a seizure diary to identify YOUR patterns
• Share trigger information with your doctor
• This is for educational awareness only

💡 TIP: Use NeuroGuard's seizure diary feature to track your patterns and identify personal triggers!''',

    'firstaid': '''SEIZURE FIRST AID - WHAT TO DO

If someone has a seizure, staying calm and knowing what to do can help:

✅ DURING THE SEIZURE:

1. STAY CALM
   • Don't panic - seizures are temporary
   • Remain with the person until it ends

2. KEEP PERSON SAFE
   • Move away dangerous objects
   • Clear area around them
   • Don't restrain their movements

3. POSITION SAFELY
   • If possible, place them on their side
   • This prevents choking
   • Gently support their head

4. NEVER DO THIS:
   ❌ Put anything in their mouth
   ❌ Try to hold their tongue
   ❌ Restrain their body
   ❌ Pour water on them
   ❌ Leave them alone

⏱️ AFTER THE SEIZURE:

1. Check breathing and consciousness
2. Keep person on side until fully alert
3. Offer reassurance and comfort
4. Allow time to recover (may feel confused)
5. Stay with person until normal

📞 CALL EMERGENCY SERVICES (911 in US) IF:
• This is their first seizure
• Seizure lasts more than 5 minutes
• Another seizure starts immediately after
• Person doesn't regain consciousness
• Person is injured
• You're unsure what to do

💚 RECOVERY AFTER SEIZURE:
• May feel confused or disoriented
• May be tired or want to sleep
• May have headache
• May not remember the seizure
• Reassurance helps recovery

📚 IMPORTANT:
Medical professionals should evaluate any first-time seizure. This is first aid guidance - always follow your healthcare provider's instructions.''',

    'safety': '''LIVING SAFELY WITH SEIZURES

With proper precautions, people with seizures can enjoy full, active lives:

🏡 HOME SAFETY:
• Pad sharp furniture corners
• Use cushioned rugs to prevent falls
• Keep medication easily accessible
• Install bathroom grab bars
• Consider shower vs. bathtub safety
• Keep emergency numbers visible
• Sleep on lower bed or with bed rails

🛁 BATHING SAFETY:
• Take showers rather than baths (safer)
• Avoid locking bathroom doors
• Tell someone when bathing
• Keep water temperature moderate

🚗 DRIVING:
• Check local laws (seizure-free period often required)
• Discuss with your doctor
• Avoid driving if seizure risk is high
• Use public transportation when unsure

⚽ ACTIVITIES & SPORTS:
• Most activities ARE possible with precautions
• Avoid activities alone (swimming, climbing)
• Always wear safety gear (helmet, etc.)
• Tell others about your seizures
• Take rest breaks when needed

😴 SLEEP SAFETY:
• Keep seizure medication by bedside
• Tell family/roommates about nighttime seizures
• Consider bedside phone
• Use seizure alert devices if available
• Sleep in safe position

📱 WEARABLE PROTECTION:
• Wear medical alert bracelet/necklace
• Keep emergency contact info accessible
• Use NeuroGuard app for alerts (if available)
• Share app access with trusted contacts

👥 TELL OTHERS:
• Inform close friends and coworkers
• Explain what to do during seizure
• Keep emergency contact list updated
• Don't feel embarrassed about condition

✈️ TRAVEL SAFETY:
• Keep medications in original bottles
• Carry medical documentation
• Know local emergency number
• Tell travel companions
• Keep medication with you (not checked bags)

💪 EMOTIONAL SAFETY:
• Connect with support groups
• Talk to counselor if feeling anxious
• Share concerns with healthcare provider
• Remember: Many live seizure-free lives with treatment

⚠️ REMEMBER:
These are general safety suggestions. Your doctor may have specific recommendations for YOUR situation.''',

    'lifestyle': '''HEALTHY LIFESTYLE FOR SEIZURE MANAGEMENT

While medication is primary, lifestyle factors significantly impact seizure control:

😴 SLEEP:
Why it matters: Sleep deprivation is the #1 trigger
Recommendations:
• Get 7-9 hours nightly
• Keep consistent sleep schedule
• Avoid caffeine before bed
• Create dark, cool sleep environment
• Manage sleep disorders with doctor

🧘 STRESS MANAGEMENT:
Why it matters: Stress can trigger seizures
Techniques to try:
• Deep breathing exercises
• Meditation or mindfulness
• Yoga or gentle exercise
• Progressive muscle relaxation
• Journaling or creative hobbies
• Regular exercise (30 min, 5x/week)

🥗 NUTRITION:
Why it matters: Stable blood sugar helps brain function
Recommendations:
• Eat balanced meals regularly
• Don't skip meals
• Maintain stable blood sugar
• Stay hydrated (8+ glasses water daily)
• Some research: ketogenic diet may help (discuss with doctor)
• Limit caffeine and alcohol

💧 HYDRATION:
Why it matters: Dehydration can trigger seizures
Recommendations:
• Drink adequate water daily
• More in hot weather or exercise
• Limit caffeine (dehydrating)
• Monitor urine color (pale = well hydrated)

💪 EXERCISE:
Why it matters: Improves overall health and mood
Recommendations:
• Aim for 150 min moderate activity/week
• Walking, swimming, cycling are good options
• Avoid overheating (cool breaks)
• Exercise with others when possible
• Discuss specific activities with doctor

🧠 COGNITIVE HEALTH:
Why it matters: Mental health affects seizures
Actions to take:
• Manage anxiety and depression
• Seek counseling if needed
• Stay mentally active
• Maintain social connections
• Join support groups

📝 TRACKING:
Why it matters: Identifies patterns
Try:
• Keep seizure diary in NeuroGuard
• Log sleep, stress, food, activities
• Note patterns over time
• Share with healthcare provider

⚠️ AVOID:
• Alcohol (increases seizure risk)
• Recreational drugs
• Sleep deprivation
• Extreme stress without support
• Skipping medications

✨ REMEMBER:
These changes support medical treatment - NOT a substitute. Work with your healthcare team for complete management.''',

    'eeg': '''EEG TESTING - WHAT YOU NEED TO KNOW

EEG (Electroencephalogram) is a common test for evaluating seizures:

🔍 WHAT IS EEG?
• Records electrical activity of the brain
• Uses small electrodes on scalp
• Non-invasive and painless
• Usually takes 20-60 minutes

🎯 WHY DO DOCTORS USE IT?
• Confirm seizure diagnosis
• Identify seizure type
• Locate where seizures start
• Rule out other conditions
• Monitor brain activity changes
• Sometimes capture actual seizure (diagnostic)

📊 TYPES OF EEG:
1. Routine EEG (20-30 minutes)
   - Baseline brain activity recording
   - Patient resting or with light stimulation
   
2. Sleep-Deprived EEG
   - Increases chance of capturing seizure activity
   - Patient stays awake night before
   - Helps identify patterns
   
3. Ambulatory EEG (24-72 hours)
   - Portable monitoring at home
   - Records longer periods
   - Better captures daily patterns
   
4. Video EEG (hospitalized monitoring)
   - Continuous recording in hospital
   - Medical team watches for seizures
   - Helps confirm diagnosis or plan surgery

🏥 WHAT HAPPENS DURING EEG?
1. Technician attaches small electrodes to scalp
2. Electrodes taped securely in place
3. Electrodes connect to recording machine
4. Patient rests while brain activity recorded
5. Tech may ask to open/close eyes or hyperventilate
6. Flashing lights may be used to stimulate brain
7. Usually no discomfort

✅ WHAT TO EXPECT:
• Electrodes feel like small adhesive pads
• No electrical current enters your body
• Safe procedure with no known risks
• May feel slightly uncomfortable removing electrodes
• No preparation usually needed
• Can eat, drink, and take medications normally
• Wear comfortable clothes
• Arrive early to complete paperwork

📋 BEFORE YOUR EEG:
• Wear comfortable, easy-access clothing
• Wash hair day before (improves electrode contact)
• Take regular medications unless told otherwise
• Eat normally unless instructed otherwise
• Bring list of current medications
• Tell tech about scalp conditions or allergies

⚠️ SPECIAL INSTRUCTIONS:
• Sleep-deprived EEG: Stay awake previous night
• Ambulatory EEG: Keep diary of activities
• Avoid lotions/products on scalp for routine EEG

📱 AFTER YOUR EEG:
• Can resume normal activities immediately
• Results sent to doctor
• Doctor reviews and explains findings
• May be discussed at next appointment
• Results help guide treatment decisions

💭 IMPORTANT TO KNOW:
• Normal EEG doesn't rule out epilepsy
• Abnormal EEG doesn't always mean epilepsy
• Multiple tests may be needed for diagnosis
• Discuss results thoroughly with your doctor

🤔 QUESTIONS TO ASK YOUR DOCTOR:
• Why is EEG being recommended?
• Which type of EEG do I need?
• How are results used for my care?
• What do results mean for treatment?

📞 Contact your doctor if you have questions about EEG testing.''',

    'neuroguard_features': '''NEUROGUARD AI APP FEATURES

Learn how to use all the features in NeuroGuard to manage your health:

📊 DASHBOARD:
• Overview of your health status
• Recent seizure events summary
• Medication reminders
• Upcoming appointments
• Quick access to key features

📝 SEIZURE DIARY:
How to use it:
• Log each seizure occurrence
• Record date and time
• Note duration and type
• Record any triggers noticed
• Add additional notes
Why it matters:
• Helps identify patterns
• Shows doctor at appointments
• Tracks medication effectiveness
• Identifies personal triggers
Tip: Log shortly after event while details fresh

💊 MEDICATION MANAGEMENT:
Features:
• Track medications taken
• Set reminder notifications
• Log medication names and doses
• Note any side effects
• Medication history

🔔 APPOINTMENT REMINDERS:
• Schedule upcoming appointments
• Get reminders before appointments
• Track appointment history
• Notes section for each appointment
Tip: Add doctor phone number and location

⌚ BLUETOOTH WEARABLE CONNECTION:
How to connect:
1. Enable Bluetooth on phone
2. Wear your NeuroGuard band
3. Open app and go to Bluetooth settings
4. Select your device
5. Tap "Connect"
6. Follow pairing instructions

Data received:
• Heart rate measurements
• Body temperature
• Motion/activity levels
• Sleep tracking
• Real-time health metrics

💡 Tip: Keep wearable charged and within Bluetooth range for best results

📤 EEG FILE UPLOAD:
How to upload:
1. Go to EEG section
2. Tap "Upload File"
3. Select file from device
4. Supported formats: .csv, .txt, .eeg, .dat
5. AI analyzes and provides results

What happens:
• File processed by AI
• Seizure patterns detected
• Risk assessment provided
• Results visible in dashboard
• Can be shared with doctor

🚨 SEIZURE ALERTS:
When activated:
• App monitors for seizure patterns
• Alert triggers if high-risk detected
• Emergency contacts notified
• Location shared with emergency contacts
• Alert history maintained

⚙️ NOTIFICATION SETTINGS:
Customize:
• Which alerts you receive
• Alert sound and vibration
• Emergency contact list
• Alert frequency
• Do not disturb hours

👥 EMERGENCY CONTACTS:
How to set up:
1. Go to Settings
2. Select Emergency Contacts
3. Add contact name and phone
4. Select contact relationship
5. Confirm and save
Tip: Update regularly, inform contacts they're listed

📱 USING APP FEATURES SAFELY:
• Don't rely on app alone for medical decisions
• Always consult your doctor about results
• Keep wearable cleaned and maintained
• Ensure emergency contacts are current
• Report technical issues to support

❓ GETTING HELP:
• Tap "Help" in app menu
• Contact app support through app
• Visit website for user guides
• Contact your healthcare provider for medical questions

✨ REMEMBER:
NeuroGuard assists with tracking - does NOT replace medical care. Always work with your healthcare team.''',

    'bluetooth': '''BLUETOOTH WEARABLE - SETUP & TROUBLESHOOTING

Your NeuroGuard wearable band connects via Bluetooth to track your health:

📱 INITIAL SETUP:

Step 1: Prepare
• Ensure Bluetooth is enabled on phone
• Wearable band is charged
• You're in clean environment (no interference)
• Phone is unlocked

Step 2: Open App
• Launch NeuroGuard app
• Go to Wearable/Bluetooth section
• Tap "Add New Device"

Step 3: Start Pairing
• Wearable enters pairing mode (light flashing)
• App scans for devices
• Select your NeuroGuard device from list
• Accept pairing request

Step 4: Complete Pairing
• Confirm on both phone and wearable
• Wait for connection confirmation
• Device name appears in connected list
• Start receiving data

⚙️ MANAGING CONNECTIONS:

Reconnecting:
• Open app
• Go to Wearable settings
• Device automatically reconnects if nearby
• If not: Tap "Reconnect" or repeat pairing

Disconnecting:
• Go to Wearable settings
• Select device
• Tap "Disconnect"
• Device stops transmitting

Data Sync:
• Happens automatically when connected
• Manual sync: Tap "Sync Now"
• Check last sync time in app
• Ensure adequate battery on both devices

🔧 TROUBLESHOOTING:

Device won't pair:
✓ Ensure Bluetooth enabled on phone
✓ Wearable charged and powered on
✓ Move closer to phone
✓ Restart both devices
✓ Forget device and re-pair
✓ Restart app

Connection keeps dropping:
✓ Ensure adequate battery on wearable
✓ Move away from interference (microwaves, WiFi routers)
✓ Update app to latest version
✓ Restart wearable
✓ Check for app updates

Data not syncing:
✓ Verify connection active
✓ Check internet connection
✓ Tap "Sync Now"
✓ Restart app
✓ Check phone storage space

Wearable not recognized:
✓ Forget and re-pair device
✓ Reset wearable (hold button 10 seconds)
✓ Ensure app permissions enabled
✓ Check Bluetooth settings

⚠️ IF PROBLEMS PERSIST:
• Contact app support through "Help" menu
• Provide device and phone model info
• Describe exact problem
• Include when problem started

💡 BEST PRACTICES:

Maintain Connection:
• Keep phone nearby during use
• Enable Bluetooth at all times
• Keep wearable charged (low battery affects connection)
• Avoid interference from other devices
• Use in open areas when possible

Improve Signal:
• Remove wearable from closed spaces
• Don't block Bluetooth antenna
• Keep phone in pocket or hand
• Minimize distance between devices

Care for Wearable:
• Keep clean and dry
• Charge regularly
• Avoid extreme temperatures
• Don't submerge if not waterproof
• Store in safe location when not wearing

Privacy & Security:
• Only pair with your personal phone
• Don't share pairing information
• Disconnect from unfamiliar networks
• Keep app updated for security

✨ REMEMBER:
Wearable connection helps track your health. Work with your doctor to interpret data. Contact support for technical issues.''',

    'medication': '''⚠️ MEDICATION INFORMATION & ADHERENCE

I CANNOT prescribe, recommend, or advise on medication dosages. Only your doctor can make medication decisions.

🏥 WHY MEDICATION PRESCRIBED:
Medications help control seizures by:
• Reducing abnormal brain electrical activity
• Preventing seizure occurrence
• Making existing seizures less severe
• Allowing normal daily activities

👨‍⚕️ YOUR DOCTOR DETERMINES:
• WHICH medication(s) for YOUR condition
• WHAT DOSE appropriate for you
• HOW OFTEN to take medication
• ANY ADJUSTMENTS needed over time

❌ WHAT I CANNOT DO:
• Recommend specific medications
• Suggest dosages or changes
• Tell you to stop taking medication
• Advise about side effects management
• Recommend stopping/starting drugs

✅ WHAT YOU SHOULD DO:

Take Medication as Prescribed:
• Take exactly as doctor prescribed
• Don't change dose without doctor approval
• Don't skip doses
• Don't stop suddenly (dangerous)
• Use NeuroGuard app to track doses

Report to Your Doctor:
• Any side effects you experience
• If medication doesn't seem effective
• Any new symptoms
• Concerns about medication
• Plans to get pregnant/breastfeed

Ask Your Doctor:
• What this medication does
• Why chosen for your situation
• Potential side effects
• Drug interactions
• What to do if dose missed
• When effects should be noticed
• Cost and insurance coverage

💊 MEDICATION ADHERENCE:

Why it's important:
• Missing doses INCREASES seizure risk
• Consistent levels prevent seizures
• Skipping doses dangerous

Tips for remembering:
• Use NeuroGuard reminders
• Take with meals (consistent timing)
• Use pill organizer
• Set phone alarm
• Keep medications visible
• Link to daily routine

🚨 EMERGENCY SITUATIONS:

If dose missed:
• CALL YOUR DOCTOR or pharmacist
• Don't double dose next time
• Continue normal schedule
• Follow healthcare provider advice

If overdose suspected:
• CALL POISON CONTROL (1-800-222-1222 in US)
• CALL 911
• GET IMMEDIATE MEDICAL HELP

🔄 REFILLS & MANAGEMENT:
• Keep prescription updated
• Don't wait until last dose
• Check expiration dates
• Store properly (cool, dry place)
• Keep with you when traveling

⚠️ REMEMBER:
This is general medication information. NEVER make medication changes without your doctor. Your doctor tailors medication to YOUR unique situation.

📞 QUESTIONS? Ask your doctor or pharmacist - they know YOUR medical history.''',

    'emergency': '''🚨 WHEN TO SEEK EMERGENCY CARE

Know when to call emergency services (911 in US) or go to hospital:

⏰ CALL 911 IF:

Seizure-Related:
• First-time seizure
• Seizure lasting longer than 5 minutes
• Multiple seizures without regaining consciousness
• Difficulty breathing during/after seizure
• Injury during seizure
• Severe head trauma

Medical Emergency Signs:
• Chest pain or difficulty breathing
• Severe head injury
• Uncontrolled bleeding
• Loss of consciousness for extended time
• Severe allergic reaction
• Signs of stroke (facial drooping, arm weakness, speech difficulty)
• Serious injury

Other Emergencies:
• Can't wake person
• Choking
• Poisoning/overdose
• Severe allergic reaction
• High fever with confusion

🚑 GO TO EMERGENCY ROOM IF:

Seizure-Related:
• Seizure cluster (multiple in short time)
• Post-seizure confusion lasting >1 hour
• Seizure in water (aspiration risk)
• Pregnancy-related seizure
• Any seizure concerns you

Medical Concerns:
• Chest pain
• Shortness of breath
• Severe abdominal pain
• Severe bleeding
• Possible broken bones
• Head injury with symptoms
• Signs of infection (high fever)

🏥 CALL DOCTOR'S OFFICE IF:

Non-Emergency Concerns:
• Mild medication side effects
• Questions about medication
• Regular follow-up needed
• Pattern changes in seizures
• Minor injuries/concerns
• Medication refill needed

⏱️ DURING EMERGENCY:

What to do:
1. STAY CALM
2. CALL 911 immediately
3. Provide address/location
4. Answer dispatcher questions
5. Follow their instructions
6. Stay with person until help arrives
7. Give medical information to paramedics

What to tell paramedics:
• Person has epilepsy/seizures
• Seizure duration
• Medications they take
• Allergies
• Recent medical history
• Emergency contacts

📋 PREPARE FOR EMERGENCIES:

Before Emergencies Happen:
• Keep medical alert information accessible
• Wear medical ID bracelet
• Program emergency contacts in phone
• Keep medication list updated
• Know your address for emergencies
• Have important medical info memorized

In Your Home:
• Keep phone accessible near bed
• List emergency numbers visible
• Keep medications easily accessible
• Know nearest hospital location

When Traveling:
• Know local emergency number
• Have medical info copies
• Carry medications with you
• Tell travel companions about condition
• Know nearby hospitals

📱 NEUROGUARD EMERGENCY FEATURES:
• Emergency contact alerts
• Location sharing enabled
• Important medical info stored
• Medication list accessible
• Doctor contact information saved

⚠️ REMEMBER:
• Calling emergency services is ALWAYS the right choice if unsure
• Don't worry about "bothering" paramedics
• It's better to be safe
• Paramedics trained to help
• This is what they do

📞 Know these numbers:
• Emergency: 911 (US)
• Poison Control: 1-800-222-1222 (US)
• Ambulance/Hospital: Know nearest facility
• Doctor's after-hours line: Program in phone

✨ TAKE ACTION NOW:
1. Program emergency numbers
2. Update emergency contacts
3. Wear medical ID
4. Share condition with close contacts
5. Know your nearest hospital''',

    'hello': '''👋 WELCOME TO NEUROGUARD AI HEALTH ASSISTANT

I'm here to provide educational information about seizures, epilepsy, and how to use NeuroGuard.

⚠️ IMPORTANT DISCLAIMER:
This assistant provides INFORMATION ONLY:
✗ I cannot diagnose medical conditions
✗ I cannot prescribe medications
✗ I cannot provide medical advice
✗ I cannot replace your doctor
✗ I cannot provide emergency care

✅ What I CAN help with:
📚 Epilepsy & seizure education
📋 Types of seizures and symptoms
🆘 First aid during seizures
🛡️ Safety precautions and lifestyle
⚕️ Understanding medical tests
💊 General medication information
⏰ Seizure triggers and patterns
📱 NeuroGuard app features
⌚ Bluetooth wearable setup
📤 EEG file upload guidance

❓ HOW TO ASK QUESTIONS:
Just type naturally! For example:
• "Tell me about seizures"
• "What are common triggers?"
• "First aid for seizures"
• "How to use Bluetooth"
• "Seizure diary tips"
• "When to call 911"

📞 FOR MEDICAL DECISIONS:
• Always consult your healthcare provider
• Don't rely on this chat for diagnosis
• Share information with your doctor
• Ask your doctor about any concerns

🏥 EMERGENCY? CALL 911 (US)
Or your local emergency number immediately.

💪 YOU'RE NOT ALONE:
• Millions of people have seizure disorders
• Many live full, active lives
• Treatment options available
• Support communities exist
• NeuroGuard is here to help

👇 Try asking about:
• Seizures and epilepsy
• Safety and first aid
• Lifestyle management
• App features
• NeuroGuard usage

Let's get started! What would you like to learn about?'''
  };

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final int parsedUserId = int.tryParse(widget.userId) ?? 0;
      final res = await ApiService.getChatHistory(parsedUserId);
      if (res['status'] == 'success') {
        final List<dynamic> conv = res['conversations'] ?? [];
        setState(() {
          _messages.clear();
          for (var m in conv) {
            try {
              final ts = m['timestamp'] ?? DateTime.now().toIso8601String();
              _messages.add(ChatMessage(
                text: m['text'] ?? '',
                isUser: (m['is_user'] ?? 0) == 1,
                timestamp: DateTime.parse(ts),
              ));
            } catch (e) {
              _messages.add(ChatMessage(
                text: m['text'] ?? '',
                isUser: (m['is_user'] ?? 0) == 1,
                timestamp: DateTime.now(),
              ));
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to load chat history: $e');
    }

    // If no previous history, add the welcome message and persist it
    if (_messages.isEmpty) {
      final welcome = 'Hello! 👋 I\'m the NeuroGuard AI Assistant. I can provide information about seizures and neurological health. '
          'Ask me about seizures, EEG, symptoms, medication, triggers, or safety tips. '
          '⚠️ Remember: I provide information only and cannot replace medical advice.';
      _addMessage(welcome, false);
      await _saveMessageToDb(welcome, false, DateTime.now());
    }
  }

  Future<void> _saveMessageToDb(String text, bool isUser, DateTime timestamp) async {
    try {
      await ApiService.saveChatMessage(
        userId: int.tryParse(widget.userId) ?? 0,
        text: text,
        isUser: isUser,
        timestamp: timestamp.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Failed to save chat message: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Tracks the last topic discussed for conversational continuity
  String _lastTopic = '';

  /// Safety disclaimer injected into high-risk responses
  static final String _safetyDisclaimer =
      '⚠️ This information is for general educational purposes only and is not a medical diagnosis or prescription. '
      'Please consult your doctor or neurologist before making any changes to your treatment. '
      'If this is an emergency, contact your local emergency services immediately.';

  /// High-risk topic keywords that trigger the safety disclaimer
  static final RegExp _highRiskPattern = RegExp(
    r'\b(dose|dosage|stop |stopping|change .*med|pregnan|chest pain|suicid|allergic|lost conscious|unconscious|'
    r'severe .*symptom|worsen|lactation|breastfeed|child .*seizure|infant|toddler|overdose)\b',
    caseSensitive: false,
  );

  String _generateResponse(String userMessage) {
    final lower = userMessage.toLowerCase().trim();

    // --- 0. Conversation continuations ---
    if (_lastTopic.isNotEmpty) {
      if (lower.contains(RegExp(r'\b(more|tell more|explain|elaborate|go on|continue|detail)\b'))) {
        switch (_lastTopic) {
          case 'seizure': return _generateSeizureResponse('types causes prevention');
          case 'firstaid': return _generateFirstAidResponse('recovery aftercare');
          case 'triggers': return _knowledgeBase['lifestyle']!;
          case 'lifestyle': return _generateLifestyleResponse('sleep stress diet');
          case 'medication': return _generateSideEffectsResponse('');
          case 'eeg': return _knowledgeBase['eeg']!;
          default: break;
        }
      }
      if (lower.contains(RegExp(r'\b(why|how|what about|also|and)\b')) && lower.length < 40) {
        return _generateTopicResponse(_lastTopic, lower);
      }
      // No continuation detected — fall through
      _lastTopic = '';
    }

    // --- 1. Greetings ---
    if (RegExp(r'\b(hi|hello|hey|greetings|good morning|good evening|good afternoon|howdy)\b').hasMatch(lower)) {
      _lastTopic = 'greeting';
      return _knowledgeBase['hello']!;
    }

    // --- 2. Emergency / Urgent ---
    if (RegExp(r'\b(emergency|911|help me|urgent|critical|ambulance|rescue)\b').hasMatch(lower)) {
      _lastTopic = '';
      return '''🚨 EMERGENCY

If you are experiencing a medical emergency:
• CALL your local emergency services immediately (911 in the US)
• Do NOT wait or try to drive yourself
• Get immediate medical attention

In case of an active seizure:
1. Keep the person safe from injury
2. Place them on their side
3. Do NOT put anything in their mouth
4. Time the seizure
5. Call emergency services if it lasts more than 5 minutes

This chatbot cannot provide emergency assistance. If you need urgent help, please contact emergency services now.$_safetyDisclaimer''';
    }

    // --- 3. Core knowledge base matching ---
    for (final entry in _knowledgeBase.entries) {
      if (entry.key.length > 3 && lower.contains(entry.key)) {
        _lastTopic = entry.key;
        return entry.value + (entry.key == 'medication' || entry.key == 'emergency' ? _safetyDisclaimer : '');
      }
    }

    // --- 4. Broad topic categories ---
    final topic = _detectTopic(lower);
    _lastTopic = topic;
    final response = _generateTopicResponse(topic, lower);
    final needsSafety = _highRiskPattern.hasMatch(lower);
    return response + (needsSafety ? _safetyDisclaimer : '');
  }

  /// Detects the best-matching topic category for any user query
  String _detectTopic(String msg) {
    if (RegExp(r'\b(what is epilepsy|about epilepsy|epilepsy|neurological disorder)\b').hasMatch(msg)) return 'seizure';
    if (RegExp(r'\b(seizure|convulsion|fit|attack|spasm|jerking|shaking)\b').hasMatch(msg)) return 'seizure';
    if (RegExp(r'\b(first aid|what to do during|help someone|emergency response|recovery position)\b').hasMatch(msg)) return 'firstaid';
    if (RegExp(r'\b(trigger|cause|provoke|bring on|set off|induce|precipitate)\b').hasMatch(msg)) return 'triggers';
    if (RegExp(r'\b(symptom|sign|warning|aura|feeling before|prodrome|premonitory)\b').hasMatch(msg)) return 'symptoms';
    if (RegExp(r'\b(safe|safety|precaution|avoid|protect|prevent|risk)\b').hasMatch(msg)) return 'safety';
    if (RegExp(r'\b(lifestyle|diet|nutrition|eat|food|meal|weight|obesity|exercise|workout|fit|activity|sport)\b').hasMatch(msg)) return 'lifestyle';
    if (RegExp(r'\b(sleep|insomnia|rest|tired|fatigue|nap|bedtime|circadian)\b').hasMatch(msg)) return 'sleep';
    if (RegExp(r'\b(stress|anxiety|anxious|worry|mental|depression|mood|emotion|calm|relax|meditation|mindfulness)\b').hasMatch(msg)) return 'stress';
    if (RegExp(r'\b(hydrat|water|drink|fluid|dehydrat|thirst)\b').hasMatch(msg)) return 'hydration';
    if (RegExp(r'\b(medicine|drug|pill|tablet|prescription|pharmacy|refill|anti.?seizure|anti.?epileptic|AED|ASM)\b').hasMatch(msg)) return 'medication';
    if (RegExp(r'\b(dose|dosage|mg |milligram|how much|how many|strength)\b').hasMatch(msg)) return 'medication';
    if (RegExp(r'\b(side effect|adverse|reaction|allerg|rash|dizzy|drowsy|nausea|weight gain|hair loss|tremor)\b').hasMatch(msg)) return 'sideeffects';
    if (RegExp(r'\b(missed dose|forgot|skip|remember|adherence|compliance|routine|schedule)\b').hasMatch(msg)) return 'adherence';
    if (RegExp(r'\b(eeg|electroencephalogram|brain scan|brain wave|neurologist|test|diagnose|MRI|CT scan|imaging)\b').hasMatch(msg)) return 'eeg';
    if (RegExp(r'\b(doctor|appointment|follow.?up|check.?up|visit|consult|neurologist|specialist|epileptologist)\b').hasMatch(msg)) return 'appointments';
    if (RegExp(r'\b(pregnan|birth|mother|baby|fetal|conception|fertility|breastfeeding|lactation)\b').hasMatch(msg)) return 'pregnancy';
    if (RegExp(r'\b(child|kid|toddler|infant|baby|pediatric|school|teen|adolescent|parent)\b').hasMatch(msg)) return 'children';
    if (RegExp(r'\b(caregiver|care for|looking after|family|support|helping|assisting)\b').hasMatch(msg)) return 'caregiver';
    if (RegExp(r'\b(drive|driving|car|vehicle|license|transport)\b').hasMatch(msg)) return 'driving';
    if (RegExp(r'\b(travel|trip|vacation|flight|journey|abroad)\b').hasMatch(msg)) return 'travel';
    if (RegExp(r'\b(alcohol|drink|wine|beer|liquor|caffeine|coffee|smoking|cigarette|drug|recreational)\b').hasMatch(msg)) return 'substances';
    if (RegExp(r'\b(diary|track|log|record|journal|monitor|pattern)\b').hasMatch(msg)) return 'tracking';
    if (RegExp(r'\b(sudep|sudden death|unexpected death|mortality)\b').hasMatch(msg)) return 'sudep';
    if (RegExp(r'\b(wearable|watch|band|bluetooth|sensor|connect|pair|device|sync|hardware)\b').hasMatch(msg)) return 'bluetooth';
    if (RegExp(r'\b(app|neuroguard|feature|setting|how to use|navigate|dashboard|profile)\b').hasMatch(msg)) return 'neuroguard_features';
    if (RegExp(r'\b(surgery|operation|brain surgery|resection|implant|VNS|RNS|DBS|responsive neurostimulation)\b').hasMatch(msg)) return 'surgery';
    if (RegExp(r'\b(thank|thanks|appreciate|helpful|great|good job|awesome)\b').hasMatch(msg)) return 'thanks';
    if (RegExp(r'\b(bye|goodbye|see you|farewell|take care|later)\b').hasMatch(msg)) return 'bye';
    if (msg.split(' ').length <= 2) return 'short';
    return 'general';
  }

  /// Generates a tailored educational response for each topic category
  String _generateTopicResponse(String topic, String query) {
    switch (topic) {
      // -------------------------------------------------------
      case 'seizure':
        return _generateSeizureResponse(query);
      case 'symptoms':
        return _knowledgeBase['symptoms']!;
      case 'triggers':
        return _knowledgeBase['triggers']!;
      case 'firstaid':
        return _generateFirstAidResponse(query);
      case 'safety':
        return _knowledgeBase['safety']!;
      // -------------------------------------------------------
      case 'lifestyle':
        return _generateLifestyleResponse(query);
      case 'sleep':
        return _generateSleepResponse();
      case 'stress':
        return _generateStressResponse();
      case 'hydration':
        return _generateHydrationResponse();
      // -------------------------------------------------------
      case 'medication':
        return _knowledgeBase['medication']!;
      case 'sideeffects':
        return _generateSideEffectsResponse(query);
      case 'adherence':
        return _generateAdherenceResponse();
      // -------------------------------------------------------
      case 'eeg':
        return _knowledgeBase['eeg']!;
      case 'appointments':
        return _generateAppointmentsResponse();
      case 'pregnancy':
        return _generatePregnancyResponse();
      case 'children':
        return _generateChildrenResponse();
      case 'caregiver':
        return _generateCaregiverResponse();
      case 'driving':
        return _generateDrivingResponse();
      case 'travel':
        return _generateTravelResponse();
      case 'substances':
        return _generateSubstancesResponse();
      case 'tracking':
        return _generateTrackingResponse();
      case 'sudep':
        return _generateSudepResponse();
      case 'surgery':
        return _generateSurgeryResponse();
      // -------------------------------------------------------
      case 'bluetooth':
        return _knowledgeBase['bluetooth']!;
      case 'neuroguard_features':
        return _knowledgeBase['neuroguard_features']!;
      // -------------------------------------------------------
      case 'thanks':
        return "You're very welcome! 😊 I'm glad I could help. If you have any more questions about epilepsy, seizures, or healthy living, feel free to ask anytime. Take care!";
      case 'bye':
        return "Take care! 👋 Remember to stay consistent with your medication and keep your doctor informed. I'm here whenever you need health information. Goodbye!";
      // -------------------------------------------------------
      case 'short':
        return '''I'd love to help! Could you tell me a bit more about what you'd like to know?

I can provide educational information about:
• Epilepsy and seizure types
• First aid and safety
• Healthy lifestyle habits
• Medication adherence tips
• Understanding medical tests
• Managing triggers
• And much more!

Just ask a question and I'll do my best to help.$_safetyDisclaimer''';
      // -------------------------------------------------------
      case 'general':
      default:
        return '''Great question! Here's what I can share based on general health knowledge:

Healthcare covers many important areas for people with epilepsy:
• **Regular check-ups** with your neurologist help monitor your condition and adjust treatment as needed
• **Seizure tracking** helps you and your doctor identify patterns and triggers
• **Healthy habits** like consistent sleep, balanced nutrition, and stress management support overall well-being
• **Medication adherence** is crucial — taking prescribed medicines on schedule helps prevent breakthrough seizures
• **Safety precautions** at home, work, and during activities reduce injury risk

I'm happy to explore any of these topics in more detail! You can also ask me about specific seizure types, first aid techniques, lifestyle tips, medication information, EEG testing, and more.

💡 Try asking me directly about what interests you — for example: "What are common seizure triggers?" or "Tips for better sleep?"

Is there a specific area you'd like me to explain?$_safetyDisclaimer''';
    }
  }

  // ===================== DYNAMIC RESPONSE GENERATORS =====================

  String _generateSeizureResponse(String query) {
    if (query.contains('type') || query.contains('kind') || query.contains('classification')) {
      return '''TYPES OF SEIZURES

Seizures are broadly classified into two main categories:

🔹 **Focal (Partial) Seizures** — start in one area of the brain:
• Focal aware: You remain conscious but may experience unusual sensations, emotions, or movements
• Focal impaired awareness: Awareness is affected; you may stare blankly or perform repetitive movements

🔹 **Generalized Seizures** — involve both sides of the brain from the start: • Absence: Brief staring spells, common in children
• Tonic-Clonic: Loss of consciousness with stiffening and jerking movements
• Myoclonic: Sudden brief muscle jerks
• Atonic: Sudden loss of muscle tone ("drop attacks")
• Tonic: Muscle stiffening
• Clonic: Rhythmic jerking movements

Your neurologist can identify YOUR specific seizure type through EEG monitoring and clinical evaluation. Treatment is tailored to your seizure type.$_safetyDisclaimer''';
    }
    return _knowledgeBase['seizure']!;
  }

  String _generateFirstAidResponse(String query) {
    if (query.contains('recover') || query.contains('after') || query.contains('post')) {
      return '''AFTER A SEIZURE — RECOVERY & AFTERCARE

Once the seizure ends, here's how to help:

✅ Immediate aftercare:
• Keep the person on their side (recovery position)
• Check breathing — it should return to normal within minutes
• Stay calm and speak gently — they may be confused or disoriented
• Allow them to rest; they may want to sleep

⚠️ What to watch for:
• Confusion lasting more than 30-60 minutes
• Difficulty breathing
• Injury from falling or jerking
• Repeated seizures without regaining consciousness

📋 After recovery:
• Note the time and duration of the seizure
• Document what happened for your doctor
• Resume normal medication schedule (do NOT double-dose)
• Contact your healthcare provider if this was unusual for you

Most people recover fully within 30-60 minutes, though fatigue may last longer.$_safetyDisclaimer''';
    }
    return _knowledgeBase['firstaid']!;
  }

  String _generateLifestyleResponse(String query) {
    return '''HEALTHY LIFESTYLE FOR EPILEPSY MANAGEMENT

A balanced lifestyle can significantly support seizure control alongside your medical treatment:

🥗 **Nutrition:**
• Eat regular, balanced meals to keep blood sugar stable
• Include fruits, vegetables, whole grains, and lean proteins
• Stay hydrated throughout the day
• Some people benefit from a ketogenic diet — discuss with your doctor first

💪 **Physical Activity:**
• Regular moderate exercise (walking, swimming, cycling) is recommended
• Aim for about 30 minutes most days
• Exercise with a buddy when possible
• Avoid overheating — take breaks as needed

🧠 **Cognitive Health:**
• Stay mentally active through reading, puzzles, or learning
• Manage anxiety and depression proactively
• Connect with support groups — you're not alone
• Consider mindfulness or relaxation techniques

📝 **Routine matters:**
• Consistent daily schedule supports brain stability
• Plan meals and sleep at regular times
• Keep a seizure diary to identify patterns

These recommendations support — but do NOT replace — your medical treatment.$_safetyDisclaimer''';
  }

  String _generateSleepResponse() {
    return '''😴 SLEEP & EPILEPSY

Sleep and seizures are closely connected. Here's what helps:

🌙 **Why sleep matters:**
• Sleep deprivation is one of the most common seizure triggers
• During deep sleep, the brain stabilizes electrical activity
• Poor sleep quality can lower the seizure threshold

✅ **Tips for better sleep:**
• Go to bed and wake up at the same time every day — even on weekends
• Create a dark, quiet, cool bedroom environment
• Avoid screens (phone, TV, tablet) at least 1 hour before bed
• Limit caffeine after 2 PM
• Try a relaxing bedtime routine: reading, gentle stretching, or warm bath
• Avoid heavy meals right before bed

📊 **If you're tracking:**
• Note your sleep hours in your seizure diary
• Look for patterns between poor sleep nights and seizure days
• Share sleep data with your neurologist

🩺 If you consistently struggle with sleep, talk to your doctor. Sleep disorders like sleep apnea can affect seizure control.$_safetyDisclaimer''';
  }

  String _generateStressResponse() {
    return '''🧘 STRESS MANAGEMENT & EPILEPSY

Stress is a well-known trigger for many people with epilepsy. Managing it can make a meaningful difference:

🎯 **Simple techniques:**
• Deep breathing: Inhale for 4 counts, hold for 4, exhale for 6 — repeat 5 times
• Progressive muscle relaxation: Tense and release each muscle group from toes to head
• Mindfulness: Focus on the present moment without judgment for 5-10 minutes daily
• Journaling: Write down thoughts and feelings to process them

🌿 **Lifestyle approaches:**
• Regular physical activity reduces stress hormones
• Connect with supportive friends and family
• Set realistic goals and boundaries — it's okay to say no
• Engage in hobbies you enjoy
• Spend time outdoors in nature

👥 **Support matters:**
• Epilepsy support groups (in-person or online) connect you with others who understand
• Counseling or therapy can provide coping tools
• Educating loved ones about epilepsy reduces anxiety for everyone

If stress feels overwhelming or persistent, please speak with your healthcare provider.$_safetyDisclaimer''';
  }

  String _generateHydrationResponse() {
    return '''💧 HYDRATION & SEIZURE HEALTH

Proper hydration is essential for brain function and may help reduce seizure risk:

🔬 **Why it matters:**
• Dehydration can alter electrolyte balance, which affects brain electrical activity
• Even mild dehydration may increase the seizure threshold in some people
• Some anti-seizure medications can increase the risk of dehydration

✅ **How to stay hydrated:**
• Aim for about 8 glasses (2 liters) of water daily
• Drink more in hot weather or during exercise
• Keep a water bottle with you throughout the day
• Eat water-rich foods: cucumbers, watermelon, oranges, soups
• Limit caffeine and alcohol, which can be dehydrating

📋 **Tips that help:**
• Set reminders to drink water regularly
• Check your urine color — pale yellow means you're well hydrated
• Flavor water with lemon, cucumber, or mint if plain water is unappealing
• Replace fluids lost during exercise

Consistent hydration is one simple habit that supports your overall brain health.$_safetyDisclaimer''';
  }

  String _generateSideEffectsResponse(String query) {
    return '''⚠️ MEDICATION SIDE EFFECTS — GENERAL INFORMATION

Every anti-seizure medication (ASM) has potential side effects, but they vary greatly from person to person:

📋 **Common types of side effects (varies by medication):**
• Dizziness or drowsiness — often temporary as your body adjusts
• Nausea or stomach upset — may improve by taking with food
• Mood changes — discuss any mood shifts with your doctor
• Weight changes — some medications may affect appetite
• Cognitive effects — difficulty concentrating or word-finding
• Skin rash — report ANY rash to your doctor immediately
• Tremor or coordination issues

✅ **What you should do:**
• Report any side effects to your doctor — never suffer in silence
• Do NOT stop medication abruptly — this can trigger severe seizures
• Ask your doctor if side effects might improve over time or with dose adjustment
• Keep a log of when side effects occur and their severity

🩺 Your doctor may adjust your dose, switch medications, or add strategies to manage side effects — but only under medical supervision.

This is general information. Your specific side effects depend on your individual medication and health profile.$_safetyDisclaimer''';
  }

  String _generateAdherenceResponse() {
    return '''💊 MEDICATION ADHERENCE — STAYING ON TRACK

Taking your medication consistently is one of the most important things you can do for seizure control:

📊 **Why consistency matters:**
• Anti-seizure medications work by maintaining steady levels in your bloodstream
• Missing doses can cause levels to drop, increasing your risk of a breakthrough seizure
• Abruptly stopping medication can trigger severe or prolonged seizures (status epilepticus)

✅ **Practical strategies:**
• Take medication at the same times each day — link it to a daily routine (meals, brushing teeth)
• Use a pill organizer marked with days of the week
• Set daily alarms or reminders on your phone
• Use the NeuroGuard app to track and get reminders
• Keep a backup dose in your bag or at work for emergencies
• Set calendar reminders for prescription refills — don't wait until you're out

🤔 **If you miss a dose:**
• Take it as soon as you remember UNLESS it's nearly time for your next dose
• Do NOT double the next dose
• Contact your doctor or pharmacist for specific guidance based on your medication

📞 Keep an open conversation with your healthcare team about any adherence challenges.$_safetyDisclaimer''';
  }

  String _generateAppointmentsResponse() {
    return '''🏥 DOCTOR APPOINTMENTS & FOLLOW-UP CARE

Regular medical follow-up is essential for managing epilepsy effectively:

📋 **What to expect at appointments:**
• Review of seizure frequency, type, and any changes since last visit
• Discussion of medication effectiveness and side effects
• Possible blood tests to monitor medication levels or organ function
• EEG or imaging if clinically indicated
• Adjustments to your treatment plan if needed

✅ **Preparing for your appointment:**
• Bring your seizure diary or tracking log
• List all medications including doses and timing
• Write down questions in advance — it's easy to forget during the visit
• Note any new symptoms, triggers, or side effects
• Bring a family member or friend for support if helpful
• Keep a list of all your healthcare providers and medications

📞 **Between appointments:**
• Don't wait for your next visit if something concerns you — call your doctor's office
• Refill prescriptions before they run out
• Update your seizure log regularly

Regular communication with your healthcare team leads to better outcomes.$_safetyDisclaimer''';
  }

  String _generatePregnancyResponse() {
    return '''🤰 EPILEPSY & PREGNANCY — EDUCATIONAL OVERVIEW

Pregnancy with epilepsy requires careful planning and medical supervision:

🔬 **Key facts:**
• Over 90% of women with epilepsy have healthy pregnancies and babies
• Some anti-seizure medications carry higher risks during pregnancy than others
• Seizure frequency may change during pregnancy due to hormonal shifts
• Pre-conception planning with your neurologist and obstetrician is strongly recommended

✅ **Important steps:**
• Discuss pregnancy plans with your neurologist BEFORE conception
• Review your medication — some are safer during pregnancy than others
• Take folic acid supplements as recommended by your doctor
• Maintain regular prenatal care and neurology visits throughout pregnancy
• Do NOT stop or change medication on your own — uncontrolled seizures pose risks too

⚕️ This is general educational information only. Your care plan must be individually tailored by your medical team.$_safetyDisclaimer''';
  }

  String _generateChildrenResponse() {
    return '''👶 EPILEPSY IN CHILDREN — FOR PARENTS & CAREGIVERS

Epilepsy in children presents unique considerations:

🧒 **What to know:**
• Epilepsy is one of the most common neurological conditions in children
• Many children outgrow certain types of epilepsy
• Early diagnosis and treatment lead to the best outcomes
• Children can participate in most normal activities with appropriate precautions

✅ **Tips for parents:**
• Work closely with a pediatric neurologist
• Educate your child's school and teachers about their condition
• Develop a seizure action plan for school and activities
• Ensure medication is given consistently — use reminders
• Keep a detailed seizure diary noting triggers, patterns, and duration
• Encourage normal social development — don't isolate the child
• Teach your child (age-appropriately) about their condition

🏫 **School considerations:**
• Meet with school nurse and teachers before the school year
• Provide written seizure first aid instructions
• Discuss any activity restrictions or accommodations needed
• Ensure emergency contacts are current

📞 Regular communication between parents, doctors, and school staff creates the safest environment.$_safetyDisclaimer''';
  }

  String _generateCaregiverResponse() {
    return '''👨‍👩‍👧 CAREGIVER SUPPORT & GUIDANCE

Caring for someone with epilepsy is both meaningful and challenging:

💚 **Key responsibilities:**
• Learn to recognize seizure types and their warning signs
• Know and practice seizure first aid regularly
• Ensure medications are taken on schedule
• Keep a seizure diary noting frequency, duration, and circumstances
• Attend doctor appointments and advocate for the person's needs

🛡️ **Safety at home:**
• Remove or pad sharp corners of furniture
• Use shower instead of bathtub when possible
• Keep floors clear of tripping hazards
• Install grab bars in bathrooms
• Keep emergency numbers easily accessible

🧘 **Taking care of yourself:**
• Caregiver burnout is real — make time for your own health
• Join caregiver support groups
• Accept help from family and friends
• Learn stress management techniques
• Don't feel guilty about needing a break — it makes you a better caregiver

📞 Know the emergency plan and when to call for help. You're doing important work.$_safetyDisclaimer''';
  }

  String _generateDrivingResponse() {
    return '''🚗 DRIVING & EPILEPSY — WHAT TO KNOW

Driving regulations for people with epilepsy vary by location, but key principles are universal:

⚖️ **General guidelines:**
• Most jurisdictions require a seizure-free period (typically 6-12 months) before driving
• Your doctor may be required to report your condition to licensing authorities
• Some areas allow driving if seizures only occur during sleep or have consistent warning signs
• Commercial driving usually has stricter requirements

✅ **Safety first:**
• Never drive if you feel a seizure coming on — pull over immediately if driving
• Discuss driving eligibility openly with your neurologist
• Alternative transportation: public transit, ride-sharing, family/friends, or medical transport
• If you are seizure-free on medication, discuss your driving status at each appointment

📋 **Practical considerations:**
• Know and follow your local laws — they exist to protect you and others
• Some medications may cause drowsiness that affects driving even without a seizure
• Maintain consistent medication to keep seizure control stable

Your safety and the safety of others on the road is the top priority.$_safetyDisclaimer''';
  }

  String _generateTravelResponse() {
    return '''✈️ TRAVELING WITH EPILEPSY

With good planning, people with epilepsy can travel safely:

🎒 **Before you go:**
• Pack more medication than you need — at least an extra week's supply
• Keep medications in original labeled bottles
• Carry a letter from your doctor explaining your condition and medications
• Research nearby hospitals at your destination
• Know the local emergency number (not 911 everywhere!)

✈️ **During travel:**
• Keep ALL medications in your carry-on bag — never in checked luggage
• Stay hydrated during flights
• Try to maintain your normal sleep schedule despite time zone changes
• Set alarms for medication at your usual interval, adjusting gradually for time zones
• Wear a medical ID bracelet

🏨 **At your destination:**
• Inform travel companions about your condition and seizure first aid
• Keep a copy of your seizure action plan accessible
• Avoid excessive alcohol and maintain hydration
• Get adequate rest — travel fatigue can be a trigger

Safe travels! Enjoy your trip with proper preparation.$_safetyDisclaimer''';
  }

  String _generateSubstancesResponse() {
    return '''⚠️ ALCOHOL, CAFFEINE & OTHER SUBSTANCES

Certain substances can affect seizure control:

🍷 **Alcohol:**
• Heavy drinking significantly increases seizure risk
• Even moderate intake may lower the seizure threshold in some people
• Alcohol withdrawal is a well-known seizure trigger
• Alcohol can interact dangerously with anti-seizure medications

☕ **Caffeine:**
• Moderate caffeine is generally considered safe for most people with epilepsy
• Excessive caffeine may disrupt sleep, which then increases seizure risk
• Some individuals report caffeine as a personal trigger — track your own patterns

🚭 **Smoking & nicotine:**
• Nicotine is a stimulant and may affect seizure threshold in some individuals
• Smoking interacts with liver enzymes that metabolize certain anti-seizure drugs

❌ **Recreational drugs:**
• Many recreational substances can trigger seizures or worsen epilepsy
• They may also dangerously interact with prescribed medications

✅ **Best approach:** Discuss any substance use honestly with your doctor. They can give personalized guidance based on your specific medications and seizure patterns.$_safetyDisclaimer''';
  }

  String _generateTrackingResponse() {
    return '''📓 SEIZURE TRACKING & DIARY

Keeping a seizure diary is one of the most valuable tools for managing epilepsy:

📊 **What to record:**
• Date and time of each seizure
• Duration (how long it lasted)
• Type of seizure (if known)
• What you were doing before it happened
• Any warning signs (aura) you noticed
• How you felt afterward
• Possible triggers: missed sleep, stress, missed medication, illness

✅ **Why tracking helps:**
• Identifies YOUR personal seizure patterns
• Shows your doctor how well treatment is working
• Reveals hidden triggers you might not notice otherwise
• Helps predict when seizures are more likely
• Provides objective data for medication adjustments

📱 **Using NeuroGuard:**
• The app has a built-in seizure diary feature
• Log events right after they happen while details are fresh
• Review trends over weeks and months
• Share data directly with your doctor at appointments

Consistent tracking leads to better-informed treatment decisions.$_safetyDisclaimer''';
  }

  String _generateSudepResponse() {
    return '''⚠️ UNDERSTANDING SUDEP

SUDEP stands for Sudden Unexpected Death in Epilepsy. Here are the facts:

📊 **What is known:**
• SUDEP is rare — affecting approximately 1 in 1,000 adults with epilepsy per year
• Risk is higher in people with frequent generalized tonic-clonic seizures
• The exact cause is not fully understood but may involve breathing or heart rhythm changes during seizures

✅ **Ways to reduce risk (discuss with your doctor):**
• Achieve the best possible seizure control through consistent medication
• Take medications exactly as prescribed — never skip doses
• Identify and avoid your personal seizure triggers
• Discuss nocturnal supervision options if you have nighttime seizures
• Consider seizure detection devices if recommended by your doctor
• Regular follow-up with your neurologist

🩺 Your neurologist can provide personalized guidance about your individual risk factors. This information is for awareness, not to cause fear.$_safetyDisclaimer''';
  }

  String _generateSurgeryResponse() {
    return '''🏥 EPILEPSY SURGERY — EDUCATIONAL OVERVIEW

For some people whose seizures don't respond to medication, surgery may be an option:

🔬 **When is surgery considered?**
• Seizures remain uncontrolled despite trying multiple medications (drug-resistant epilepsy)
• Seizures consistently start from one identifiable area of the brain
• Removal of that area would not cause significant loss of function
• A thorough pre-surgical evaluation confirms candidacy

📋 **Types of procedures:**
• Resective surgery: Removing the seizure focus area
• Laser ablation: Using heat to destroy a small seizure focus
• Corpus callosotomy: Severing the connection between brain hemispheres (for drop attacks)
• Neurostimulation devices (VNS, RNS, DBS): Implanted devices that modulate brain activity

✅ **Evaluation process:**
• Extended video-EEG monitoring
• High-resolution brain MRI
• Neuropsychological testing
• Sometimes PET, SPECT, or MEG scans
• Multidisciplinary team review

🩺 Only an experienced epilepsy surgery center can determine if you're a candidate. Discuss options with your neurologist.$_safetyDisclaimer''';
  }

  void _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    // Add user message locally and persist
    final now = DateTime.now();
    _addMessage(userMessage, true);
    _messageController.clear();
    await _saveMessageToDb(userMessage, true, now);

    // Generate and add bot response and persist it
    Future.delayed(Duration(milliseconds: 500), () async {
      final response = _generateResponse(userMessage);
      final respTime = DateTime.now();
      _addMessage(response, false);
      await _saveMessageToDb(response, false, respTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).chatbotTitle),
        backgroundColor: Color(0xff0B8F55),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Disclaimer banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                color: Color(0xFFFEF3C7),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB45309),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Information only - Not a substitute for medical advice. Consult your healthcare provider.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78350F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages area
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(Responsive.padding(context)),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, context);
              },
            ),
          ),

          // Input area
          Container(
            padding: EdgeInsets.all(Responsive.padding(context)),
            color: Colors.grey.shade50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick action buttons
                if (_messages.length < 3)
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        _buildQuickButton('Tell me about seizures', context),
                        _buildQuickButton('Seizure symptoms', context),
                        _buildQuickButton('Safety tips', context),
                      ],
                    ),
                  ),

                // Message input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask about seizures, EEG, symptoms...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: Color(0xff0B8F55),
                      mini: true,
                      child: Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xffE9FFF4),
              child: Icon(
                Icons.psychology,
                size: 18,
                color: Color(0xff0B8F55),
              ),
            ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Color(0xff0B8F55)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: 8),
          if (message.isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xff0B8F55),
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {
          _messageController.text = label;
          _sendMessage();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xff0B8F55)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xff0B8F55),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}




