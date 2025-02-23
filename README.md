
# Incident Management Slack Bot

This project is a Slack bot developed using Ruby on Rails and PostgreSQL, focused on managing incidents. It integrates with Slack's API to allow users to declare, resolve, and track incidents directly within Slack channels.

## Features

- **Declare Incident**: Users can declare an incident by providing a title and optional description and severity. The bot opens a modal for input and tracks the incident.
- **Resolve Incident**: Users can resolve incidents by referencing the Slack channel where the incident was declared.
- **Incident Tracking**: The bot allows for tracking active and resolved incidents, providing users with an easy way to manage incidents in real-time.

## Tech Stack

- **Backend**: Ruby on Rails
- **Database**: PostgreSQL
- **Slack API**: Used to open modals, handle interactions, and track incidents.
- **Version Control**: Git

## Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

- **Ruby** (>= 2.7.0)
- **Rails** (>= 6.0)
- **PostgreSQL** (>= 12)
- **Node.js** (>= 14.x)

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/incident-management-slack-bot.git
   cd incident-management-slack-bot
   ```

2. **Install dependencies**:

   ```bash
   bundle install
   yarn install
   ```

3. **Set up the database**:

   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

4. **Configure environment variables**:

   You'll need to set up your Slack app's credentials (such as API tokens and secrets) as environment variables. Create a `.env` file in the root directory and add:

   ```bash
   SLACK_APP_TOKEN=<your-slack-app-token>
   SLACK_BOT_TOKEN=<your-slack-bot-token>
   ```

   Replace `<your-slack-app-token>` and `<your-slack-bot-token>` with the actual tokens from your Slack app.

5. **Start the Rails server**:

   ```bash
   bin/rails server
   ```

6. **Access the app**:

   The app will be running on `http://localhost:3000`.

## How to Use

1. **Declare an Incident**:
   
   Use the following command within Slack to declare an incident:
   ```bash
   /rootly declare <incident title>
   ```

   If you don't provide a title, a default title "Untitled Incident" will be used. A modal will pop up allowing you to enter a description and select the severity level.

2. **Resolve an Incident**:

   If you're in a Slack channel with an active incident, you can resolve it by using the following command:
   ```bash
   /rootly resolve
   ```

   This will mark the incident in that channel as "resolved".

```bash
bin/rails test:integration
```

## Deployment

For deployment to production, you can use services like Heroku or any server with Docker support.


## Contributing

We welcome contributions! If you want to improve this project, please fork it, create a new branch, and submit a pull request. Here's how you can contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-name`).
6. Create a new pull request.

