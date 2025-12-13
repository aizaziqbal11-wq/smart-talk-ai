#!/bin/bash

echo "Creating Flutter lib structure..."

cd lib || exit

# Create folders
mkdir -p screens widgets models services

# Create files

touch screens/chat_screen.dart
touch widgets/chat_bubble.dart
touch widgets/chat_input.dart
touch widgets/chat_header.dart
touch models/message_model.dart
touch services/chat_service.dart

echo "Flutter template created successfully!"
