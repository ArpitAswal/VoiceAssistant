# Voice Genie
Voice Genie is a Flutter-based mobile application that acts as a voice-powered AI assistant, designed for quick, intuitive, and hands-free interactions. Leveraging the power of Gemini API and Imagine API, this single-screen app can respond to both text-based and art/image-based prompts, making it a unique blend of conversational AI and visual creativity. Through its streamlined interface, users can quickly send queries and receive spoken or visual responses, enhanced by intuitive speech-to-text and text-to-speech capabilities.

Features-

Text and Art-Based AI Responses-
Text Queries: Using Gemini API with the Gemini 1.5 Flash model, Voice Genie answers user questions or prompts with insightful responses related to organization, creativity, or general information.

Art/Image Prompts: For creative visual queries, Imagine API generates relevant images or artwork, offering a unique AI art experience.

Speech Recognition and Audio Output-
Speech-to-Text: The app converts spoken queries into text, allowing users to interact hands-free.

Text-to-Speech: Users can listen to AI responses, making information accessible and providing a conversational experience.

Interactive Display and Response Options-
Animated Text Display: Responses are displayed in rounded containers with animated text, enhancing readability and engagement.

Response Options: After receiving an AI-generated response, users can choose to:
Ask another question,
Listen to the AI response from start to finish,
Clear previous interactions and reset the screen for new prompts

Error Handling and Notifications-
Permission and Connectivity Messages: The app provides clear feedback for any permission issues (e.g., audio recording) or connectivity errors, helping users troubleshoot effortlessly.

Technology Stack-

Frontend: Flutter (Dart) for cross-platform mobile app development, ensuring a responsive and smooth user interface.

Backend: Gemini API for processing text-based queries and providing informative answers.

Imagine API for generating AI-driven image responses based on user prompts.

Additional Technologies: Speech-to-text and text-to-speech integration for streamlined voice interactions.

Usage Flow-

Starting the App: Voice Genie opens on a single main screen where users can immediately interact with AI by pressing the microphone button.

Providing a Query: Users can speak their question or prompt. The app detects the type of request:

Text-Based: The app processes queries with Gemini AI to provide textual answers.

Art/Image-Based: Imagine API is used for generating visual answers.

Displaying Results: The response, either in text or image form, appears in an animated container. Users can then:
Ask a new question,
Listen to the response through text-to-speech,
Refresh the app to reset for new queries

Handling Errors: If permissions are missing or connectivity fails, the app displays clear, specific messages to guide users in troubleshooting.

Future Updates-

Image-Based Query Analysis: A new feature will allow users to upload images to the app. Gemini AI will then analyze the uploaded image, describing its contents to provide deeper insights or contextual explanations about the image.

Enhanced AI Art Capabilities: Future updates will improve the app’s art-based prompts with more creative or style-based responses to user queries.

Design Philosophy:
Voice Genie is a sophisticated AI assistant designed to be an intuitive, accessible way for users to explore information and art with minimal effort. With future updates, it aims to become an even more interactive and personalized companion.
