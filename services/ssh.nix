{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    ports = [ 22 8022 ];
  };
  users.users = {
    root.openssh.authorizedKeys.keys = [
      ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbljDC/L0bqx0vtNSu97X6XAVNbgLz8uFiqMKG3dt9/xcVBVXnYiNZQc/1bn775TJdBX1axHexJYqSp07IXmQq6quzYMBy7ehEGded/Ga/dWWtKH/P3mcP8H3HkvUUN0Fvo6jvs765Wj8IUeI+RKx8oaeLG6VL2YOLI1hrWm/GwUQPZJccLe9MMLEHVium8TkXYxNWmWTi34JGjMtJBmfd7vLPdWgS3/djyZYbc/MYI+BZWcrL9wo0SBmFm12297Emr/M+YwVAYIbeK3QUypSSqz3TXg9awoCjr/8vO4or6Y4fD8gMzUJK/LhdX5OZDiLT7LKxdA+O7qVTgig8/JO6VPU5scm0Mas/qsJzYHpb8OOOEerwqACEOnEi1w7pdHT74eP22WXu0pbkCff+YG72tLnw3z5GhRYv3r4bqe6+0VFg+39gxDJ1g0qsJ8aU+ijXAOuUkzqzFgK7kLeh6f7by3J1rPEOSKPSqY2Vl5cNK3ZggOZ0hrZFCth3TZqSTT4j4uMlUWpF9ah1Ho1UFUI82fBcAJNLtt8dlO9bDUJl9TtIpUFlBseru+wUnD9ZiDsMmaiU/QhJGoskPUHG/HtImW5V7Ywsj0fPHXrObM3rQnVMa5LWp4SNNgyIQVSY8+BKppDEGsOW3vE3Uc2ezOdXy9YRcTWOby8QCZW6xI9ziw== martin@idk
      ''
    ];
    martin.openssh.authorizedKeys.keys = [
      ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbljDC/L0bqx0vtNSu97X6XAVNbgLz8uFiqMKG3dt9/xcVBVXnYiNZQc/1bn775TJdBX1axHexJYqSp07IXmQq6quzYMBy7ehEGded/Ga/dWWtKH/P3mcP8H3HkvUUN0Fvo6jvs765Wj8IUeI+RKx8oaeLG6VL2YOLI1hrWm/GwUQPZJccLe9MMLEHVium8TkXYxNWmWTi34JGjMtJBmfd7vLPdWgS3/djyZYbc/MYI+BZWcrL9wo0SBmFm12297Emr/M+YwVAYIbeK3QUypSSqz3TXg9awoCjr/8vO4or6Y4fD8gMzUJK/LhdX5OZDiLT7LKxdA+O7qVTgig8/JO6VPU5scm0Mas/qsJzYHpb8OOOEerwqACEOnEi1w7pdHT74eP22WXu0pbkCff+YG72tLnw3z5GhRYv3r4bqe6+0VFg+39gxDJ1g0qsJ8aU+ijXAOuUkzqzFgK7kLeh6f7by3J1rPEOSKPSqY2Vl5cNK3ZggOZ0hrZFCth3TZqSTT4j4uMlUWpF9ah1Ho1UFUI82fBcAJNLtt8dlO9bDUJl9TtIpUFlBseru+wUnD9ZiDsMmaiU/QhJGoskPUHG/HtImW5V7Ywsj0fPHXrObM3rQnVMa5LWp4SNNgyIQVSY8+BKppDEGsOW3vE3Uc2ezOdXy9YRcTWOby8QCZW6xI9ziw== martin@idk
      ''
    ];
  };
}
