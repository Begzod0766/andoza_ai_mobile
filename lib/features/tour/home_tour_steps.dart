enum HomeTourTarget { newProject, resume, estimate, shop, masters, help }

/// Tour order. The resume and estimate steps need an existing project.
List<HomeTourTarget> homeTourSteps({required bool hasProjects}) => [
      HomeTourTarget.newProject,
      if (hasProjects) ...[HomeTourTarget.resume, HomeTourTarget.estimate],
      HomeTourTarget.shop,
      HomeTourTarget.masters,
      HomeTourTarget.help,
    ];
