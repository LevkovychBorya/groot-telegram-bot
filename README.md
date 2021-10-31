<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/LevkovychBorya/groot-telegram-bot">
    <img src="assets/logo.png" alt="Logo" width="160" height="160">
  </a>

  <h3 align="center">GrootBot</h3>

  <p align="center">
    Telegram bot to help you control your smart greenhouse.
    <br />
    <a href="https://github.com/LevkovychBorya/groot-telegram-bot"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/LevkovychBorya/groot-telegram-bot">View Demo</a>
    ·
    <a href="https://github.com/LevkovychBorya/groot-telegram-bot/issues">Report Bug</a>
    ·
    <a href="https://github.com/LevkovychBorya/groot-telegram-bot/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Introduction

[![Product Name Screen Shot][product-screenshot]](http://t.me/blevkovych_bot)

The overall architecture design and technology stack is shown in the following picture:

<p align="center">
  <a href="https://github.com/LevkovychBorya/groot-telegram-bot">
    <img src="assets/architecture.png" alt="Logo" width="720" height="1280">
  </a>
</p>

The business domain of the application is agriculture.
The core functionality is based on IoT and Cloud Computing.

A list of commonly used resources that I find helpful are listed in the acknowledgements.



### Built With

Following AWS services:

 - AWS Lambda 
 - AWS API Gateway
 - AWS DynamoDB
 - AWS IoT

Telegram bot written in Python 3.8.

Raspberry Pi 4 model B see [Raspberry Pi part](https://github.com/STetiana)

* [Terraform](https://www.terraform.io)
* [Python](https://www.python.org)
* [AWS](https://aws.amazon.com)



<!-- GETTING STARTED -->
## Getting Started

Create [AWS account](https://aws.amazon.com/account/)
Create [Telegram account](https://web.telegram.org)
Install [Terraform](https://www.terraform.io/downloads.html) locally
Install [Python](https://www.python.org/downloads/release/python-3810/) locally



### Prerequisites

 - Python version: 3.8.10
 - Terraform version: 1.0.0



### Installation

1. First of all go and create a Telegram bot using [BotFather](http://t.me/botfather)

<p align="center">
  <a href="https://github.com/LevkovychBorya/groot-telegram-bot">
    <img src="assets/botfather.png" alt="Logo">
  </a>
</p>

Next go to [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) and create a secret.

Use name `TeleToken` and save your token in plaintext.

2. Go ahead and [export your AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) into the shell:

```sh
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
```

After that run:

```sh
terraform init
terraform plan
terraform apply
```

That's it. To completely finish this setup ypu need to connect your Raspberry Pi to AWS IoT service.
In oder to do that copy files from `credentials` folder to your Pi device and use them in a [script](https://github.com/STetiana) for connection.

<!-- ROADMAP -->
## Roadmap

- [] Change access for lambda and AWS IoT to least privilege

See the [open issues](https://github.com/LevkovychBorya/groot-telegram-bot/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Borys Levkovych - [@_Callmebober_](https://twitter.com/_Callmebober_) - levkovychborya@gmail.com.

Project Link: [https://github.com/LevkovychBorya/groot-telegram-bot](https://github.com/LevkovychBorya/groot-telegram-bot)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
* [terraform-best-practices](https://github.com/ozbillwang/terraform-best-practices)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/LevkovychBorya/groot-telegram-bot.svg?style=for-the-badge
[contributors-url]: https://github.com/LevkovychBorya/groot-telegram-bot/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/LevkovychBorya/groot-telegram-bot.svg?style=for-the-badge
[forks-url]: https://github.com/LevkovychBorya/groot-telegram-bot/network/members
[stars-shield]: https://img.shields.io/github/stars/LevkovychBorya/groot-telegram-bot.svg?style=for-the-badge
[stars-url]: https://github.com/LevkovychBorya/groot-telegram-bot/stargazers
[issues-shield]: https://img.shields.io/github/issues/LevkovychBorya/groot-telegram-bot.svg?style=for-the-badge
[issues-url]: https://github.com/LevkovychBorya/groot-telegram-bot/issues
[license-shield]: https://img.shields.io/github/license/LevkovychBorya/groot-telegram-bot.svg?style=for-the-badge
[license-url]: https://github.com/LevkovychBorya/groot-telegram-bot/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/boryslevkovych/
[product-screenshot]: assets/product-screenshot.png
[botfather]: assets/botfather.png
