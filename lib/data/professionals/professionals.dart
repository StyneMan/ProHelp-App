class Professionals {
  String name;
  int hourlyRate;
  String image;
  double rating;
  int reviews;
  bool isVerified;
  String excerpt;
  String location;
  List<String> skills;
  List<Experience> experiences;
  List<Education> education;
  List<Verifications> verifications;

  Professionals({
    required this.excerpt,
    required this.image,
    required this.isVerified,
    required this.location,
    required this.name,
    required this.hourlyRate,
    required this.rating,
    required this.reviews,
    required this.skills,
    required this.experiences,
    required this.education,
    required this.verifications,
  });
}

class Experience {
  String role;
  String company;
  String startDate;
  String endDate;
  bool stillHere;
  String country;
  String region;
  String companyLogo;

  Experience({
    required this.company,
    required this.companyLogo,
    required this.country,
    required this.endDate,
    required this.region,
    required this.role,
    required this.startDate,
    required this.stillHere,
  });
}

class Education {
  String course;
  String degree;
  String startDate;
  String endDate;
  bool stillHere;
  String school;
  String region;
  String country;
  String schoolLogo;

  Education({
    required this.school,
    required this.schoolLogo,
    required this.country,
    required this.endDate,
    required this.region,
    required this.course,
    required this.startDate,
    required this.stillHere,
    required this.degree,
  });
}

class Verifications {
  String document;
  String addedOn;
  bool isVerified;

  Verifications({
    required this.document,
    required this.addedOn,
    required this.isVerified,
  });
}

List<Professionals> professionals = [
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://i.guim.co.uk/img/media/42b9cbd8d07cdc3a95f0c80cf5a008bde26dd939/0_363_3297_1979/master/3297.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=850d46d0f4e3ddede19692df03707674",
    isVerified: true,
    location: "Lagos",
    name: "Miracle Okoro",
    hourlyRate: 2000,
    rating: 4.8,
    reviews: 133,
    skills: [
      "Baking",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
  ),
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://img.freepik.com/free-photo/portrait-black-man-isolated_53876-40305.jpg",
    isVerified: false,
    location: "Uyo",
    name: "Thankgod Okoro",
    hourlyRate: 2500,
    rating: 3.8,
    reviews: 120,
    skills: [
      "Designs",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
  ),
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isVerified: true,
    location: "Abuja",
    name: "King Rich",
    hourlyRate: 2000,
    rating: 4.0,
    reviews: 133,
    skills: [
      "Baking",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
      Experience(
        company: "Google",
        companyLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjlVOPsleZ9j93c7rRq4DxkQlow86W-Ydnew&usqp=CAU",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
  ),
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWxKMI371kKqsWYkrfPUwH85i49XxS9jHUbQ&usqp=CAU",
    isVerified: false,
    location: "Jos",
    name: "Thera Okoro",
    hourlyRate: 2500,
    rating: 3.8,
    reviews: 120,
    skills: [
      "Designs",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
  ),
];

List<Professionals> savedProfessionals = [
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://i.guim.co.uk/img/media/42b9cbd8d07cdc3a95f0c80cf5a008bde26dd939/0_363_3297_1979/master/3297.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=850d46d0f4e3ddede19692df03707674",
    isVerified: true,
    location: "Lagos",
    name: "Miracle Okoro",
    hourlyRate: 2000,
    rating: 4.8,
    reviews: 133,
    skills: [
      "Baking",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
  ),
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isVerified: true,
    location: "Abuja",
    name: "King Rich",
    hourlyRate: 2000,
    rating: 4.0,
    reviews: 133,
    skills: [
      "Baking",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
  ),
];

List<Professionals> hiredProfessionals = [
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://img.freepik.com/free-photo/portrait-black-man-isolated_53876-40305.jpg",
    isVerified: false,
    location: "Uyo",
    name: "Thankgod Okoro",
    hourlyRate: 2500,
    rating: 3.8,
    reviews: 120,
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
    skills: [
      "Designs",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
  ),
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isVerified: true,
    location: "Abuja",
    name: "King Rich",
    hourlyRate: 2000,
    rating: 4.0,
    reviews: 133,
    skills: [
      "Baking",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    education: [
      Education(
        school: "YABA TECH",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
  ),
  Professionals(
    excerpt: "Prefessional chef (Local and inter-continental cousines)",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWxKMI371kKqsWYkrfPUwH85i49XxS9jHUbQ&usqp=CAU",
    isVerified: false,
    location: "Jos",
    name: "Thera Okoro",
    hourlyRate: 2500,
    rating: 3.8,
    reviews: 120,
    skills: [
      "Designs",
      "Native Dish",
      "Food Arts",
      "Culinary Skills",
    ],
    verifications: [
      Verifications(
        document: "Previous work verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Certification verification",
        addedOn: "",
        isVerified: true,
      ),
      Verifications(
        document: "Guarantor verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Criminal record verification",
        addedOn: "",
        isVerified: false,
      ),
      Verifications(
        document: "Identity verification",
        addedOn: "",
        isVerified: true,
      ),
    ],
    education: [
      Education(
        school: "YABA COLLEGE OF TECHNOLOGY",
        schoolLogo:
            "https://yabatech.edu.ng/yabawebadmin/upploads/63ac269f14d6e.png",
        country: "Nigeria",
        endDate: "endDate",
        region: "Lagos",
        course: "Computer Science",
        startDate: "13/07/2021",
        stillHere: true,
        degree: "ND",
      ),
    ],
    experiences: [
      Experience(
        company: "Apple",
        companyLogo: "https://i.ytimg.com/vi/FzcfZyEhOoI/maxresdefault.jpg",
        country: "Kenya",
        endDate: "23/04/2023",
        region: "Kenyatta",
        role: "Chief Financial Officer",
        startDate: "23/06/2022",
        stillHere: false,
      ),
    ],
  ),
];
