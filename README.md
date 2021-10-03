<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/sazio/GAMELEON">
    <img src="Img/GAMELEON.png" alt="Logo" width="480" height="380">
  </a>

  <h3 align="center">Pretty GAMELEON : Pretty General Agent-based Model (for) Epidemiological (and) Logistical Enquiries On Networks</h3>

  <p align="center">
    Optimizing Urban Mobility Restrictions: a Multi Agent System for SARS-CoV-2 in the City of Toronto
    <br />
    <a href="https://github.com/sazio/GAMELEON"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/sazio/GAMELEON">View Demo</a>
    ·
    <a href="https://github.com/sazio/GAMELEON/issues">Report Bug</a>
    ·
    <a href="https://github.com/sazio/GAMELEON/issues">Request Feature</a>
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
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
GAMELEON is part of MLJC's [Datameron](https://github.com/MachineLearningJournalClub/Datameron) macro project: A bunch of students wandering around Data during the Covid-19 lockdown
### Abstract

Infectious epidemics can be simulated by employing dynamical processes as interactions on network structures. Here, we introduce techniques from the Multi-Agent System (MAS) domain in order to account for individual level characterization of societal dynamics for the SARS-CoV-2 pandemic. We hypothesize that a MAS model which considers rich spatial demographics, hourly mobility data and daily contagion information from the metropolitan area of Toronto can explain significant emerging behavior. To investigate this hypothesis we designed, with our modeling framework of choice, GAMA, an accurate environment which can be tuned to reproduce mobility and healthcare data, in our case coming from TomTom's API and Toronto's Open Data. We observed that some interesting contagion phenomena are directly influenced by mobility restrictions and curfew policies. We conclude that while our model is able to reproduce non-trivial emerging properties, large-scale simulation are needed to further investigate the role of different parameters. Finally, providing such an end-to-end model can be critical for policy-makers to compare their outcomes with past strategies in order to devise better plan for future measures. 

### Built With

* [GAMA](https://gama-platform.github.io/)
* [multiNetX](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [seaborn](https://seaborn.pydata.org/)
* [pandas](https://pandas.pydata.org/)
* [NumPy](https://numpy.org/)


<!-- GETTING STARTED -->
## Getting Started



### Prerequisites



### Installation



<!-- USAGE EXAMPLES -->
## Usage

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/sazio/GAMELEON/issues) for a list of proposed features (and known issues).


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

Distributed under the MIT License. See [`LICENSE`](https://github.com/sazio/GAMELEON/blob/master/LICENSE) for more information.



<!-- CONTACT -->
## Contact

Simone Azeglio - email: simone.azeglio@edu.unito.it - Linkedin: [https://www.linkedin.com/in/simone-azeglio](https://www.linkedin.com/in/simone-azeglio) 

Matteo Fordiani - email: matteo.fordiani@edu.unito.it - Linkedin: [https://www.linkedin.com/in/matteo-fordiani](https://www.linkedin.com/in/matteo-fordiani)

Machine Learning Journal Club (MLJC) [mljc.it](https://www.mljc.it)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

This research has been initially carried as part of a project for the course "Laboratory on advanced modeling techniques: Multi Agent Systems (MAS)", taught by Prof. Marco Maggiora at the University of Turin. We would like to personally acknowledge Jonathan Critchley for useful suggestions and feedbacks with Toronto’s  geospatial data. The implementation described in the paper is largely based on the Agent-Based framework GAMA. For the development we employed a workstation with the following technical specifications:
* CPU: Intel Core i7 10700K 8 cores / 16 threads; 
* RAM: 64 GB DDR4 unbuffered;
* GPU: Nvidia 2080 Ti 11 GB GDDR6

We deeply acknowledge the Machine Learning Journal Club for providing us with the computational resources, the University of Turin and the University of Ottawa for supporting us.


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/sazio/GAMELEON.svg?style=for-the-badge
[contributors-url]: https://github.com/sazio/GAMELEON/graphs/contributors

[forks-shield]: https://img.shields.io/github/forks/MachineLearningJournalClub/GAMELEON.svg?style=for-the-badge
[forks-url]: https://github.com/MachineLearningJournalClub/GAMELEON/network/members

[stars-shield]: https://img.shields.io/github/stars/MachineLearningJournalClub/GAMELEON.svg?style=for-the-badge
[stars-url]: https://github.com/MachineLearningJournalClub/GAMELEON/stargazers

[issues-shield]: https://img.shields.io/github/issues/MachineLearningJournalClub/GAMELEON.svg?style=for-the-badge
[issues-url]: https://github.com/MachineLearningJournalClub/GAMELEON/issues

[license-shield]: https://img.shields.io/github/license/MachineLearningJournalClub/GAMELEON.svg?style=for-the-badge
[license-url]: https://github.com/MachineLearningJournalClub/GAMELEON/blob/master/LICENSE

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/machine-learning-journal-club/

[product-screenshot]: images/screenshot.png
