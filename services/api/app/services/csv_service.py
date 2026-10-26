import csv
import io

from app.models.leads import Lead


def leads_to_csv(leads: list[Lead]) -> str:
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(
        [
            "first_name",
            "last_name",
            "title",
            "company",
            "website",
            "location",
            "email",
            "phone",
            "score",
        ]
    )
    for lead in leads:
        writer.writerow(
            [
                lead.first_name,
                lead.last_name,
                lead.title,
                lead.company,
                lead.website,
                lead.location,
                lead.email,
                lead.phone,
                lead.score_int,
            ]
        )
    return output.getvalue()
