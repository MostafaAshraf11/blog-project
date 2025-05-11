# Blog Project

## Overview
This is a Ruby on Rails API-only blog platform supporting authentication, post tagging, background job processing, and Docker-based deployment. The application uses PostgreSQL, Sidekiq, and Redis, and is containerized for easy setup.

---

## Development Environment Setup (WSL for Windows)

### **Day 1: Ubuntu and Ruby on Rails Setup**

#### 1- **Install Ubuntu via WSL (Windows only)**  
```bash
wsl --install --distribution Ubuntu-24.04
```

#### 2- **Update system packages**  
```bash
sudo apt update
sudo apt install build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev
```

#### 3- **Install mise (Ruby version manager)**  
```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

#### 4- **Install Ruby and Rails**  
```bash
mise use -g ruby@3
ruby --version
gem install rails
rails --version
```

Reference: [https://guides.rubyonrails.org/install_ruby_on_rails.html](https://guides.rubyonrails.org/install_ruby_on_rails.html)

---

## Running the Project with Docker

### **Step 1: Clone and Navigate to the Project Directory**
```bash
git clone <your-repo-url>
cd blog-project
```

### **Step 2: Build Docker Images**
```bash
docker-compose build
```

### **Step 3: Start the Application**
```bash
docker-compose up
```

The API will be accessible at: `http://localhost:3000`

---

## Services Used

- **Ruby on Rails** – Backend framework
- **PostgreSQL** – Database
- **Sidekiq** – Background job processing
- **Redis** – Message broker for Sidekiq
- **RSpec** – Testing framework
- **Docker** – Containerized development
- **Cloudinary** - Cloud file storage for user image 

---


## Background Job Configuration

Posts are automatically deleted after 24 hours using Sidekiq:
```ruby
DeletePostJob.set(wait: 24.hours).perform_later(post.id)
```

You can view the Sidekiq job queue and processing status in the browser at:
```bash
http://localhost:3000/sidekiq
```

---


## Directory Structure Overview

```
blog-project/
│
├── app/
│   ├── controllers/
│   ├── jobs/
│   ├── models/
│   └── views/
│
├── config/
│   ├── routes.rb
│   └── database.yml
│
├── db/
│   ├── migrate/
│   └── schema.rb
│
├── spec/
│   └── requests/
│
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## API Features

This API supports the following functionalities:

- User Signup and Login (JWT authentication)
- Create, Edit, and Delete Posts
- Auto-delete posts after 24 hours
- Tagging posts with dynamic tag management
- Commenting on posts
- View user profile and update account info

The full Postman collection for testing the API endpoints is included in the repository:



## Running the Test Suite

### **Step 3: Run Tests Using RSpec**
```bash
docker exec -it blog-project_demo-web_1 bundle exec rspec
```

---
