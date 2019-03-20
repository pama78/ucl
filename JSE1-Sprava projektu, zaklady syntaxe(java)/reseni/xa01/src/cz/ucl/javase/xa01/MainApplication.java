package cz.ucl.javase.xa01;

import java.util.ArrayList;
import java.util.List;

import cz.ucl.javase.xa01.company.Company;
import cz.ucl.javase.xa01.company.Programmer;
import cz.ucl.javase.xa01.company.Project;

public class MainApplication {

	public static void main(String[] args) {
		List<Company> companies = new ArrayList<Company>();
		companies.add(new Company("Alpha", 2, 1000, 90000));
		companies.add(new Company("Beta", 2, 1500, 100000));
		companies.add(new Company("Gamma", 3, 3000, 200000));
		companies.add(new Company("Delta", 5, 6000, 400000));
		companies.add(new Company("Epsilon", 6, 8000, 900000));
		companies.add(new Company("Theta", 7, 10000, 1200000));
		companies.add(new Company("Omega", 7, 20000, 20000000));

		List<Programmer> programmers = new ArrayList<Programmer>();
		programmers.add(new Programmer("Martin", 1.9, 2000));
		programmers.add(new Programmer("Jarda", 1.0, 1300));
		programmers.add(new Programmer("Lukas", 0.6, 900));
		programmers.add(new Programmer("Pepa", 1.7, 2200));
		programmers.add(new Programmer("Kamil", 0.4, 1800));
		programmers.add(new Programmer("Honza", 1.3, 1500));
		programmers.add(new Programmer("Filip", 1.1, 1000));

		List<Project> projects = new ArrayList<Project>();
		projects.add(new Project("Web", 5.0, 20000));
		projects.add(new Project("Portal", 15.0, 60000));
		projects.add(new Project("Email system", 25.0, 90000));
		projects.add(new Project("Eshop", 40.0, 150000));
		projects.add(new Project("CMS", 60.0, 250000));
		projects.add(new Project("Forum", 30.0, 35000));
		projects.add(new Project("B2B SYS", 120.0, 800000));
		projects.add(new Project("Multimedia Web", 7.0, 50000));
		projects.add(new Project("TODO List", 3.0, 10000));
		projects.add(new Project("CRM", 20.0, 80000));

		// Pro kazdou firmu je spustena simulace
		for (Company company : companies) {
			company.allocateProgrammers(programmers);
			company.allocateProjects(projects);
			company.run();
			company.printResult();

			// Protoze pri simulaci pracujeme v kazde firme se stejnymi objekty
			// programatoru a projektu, pak po kazde dokoncene simulaci pro
			// jednu firmu resetujeme programatory a projekty do vychoziho 
			// stavu, aby jim nezustal prirazen projekt a nebyla u nich evidovana
			// odvedena prace.
			for (Programmer programmer : programmers) {
				programmer.clearProject();
			}

			for (Project project : projects) {
				project.reset();
			}
		}
	}
}
