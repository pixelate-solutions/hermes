import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_flutter/src/models/hermes_models.dart';

void main() {
  test('parses core Hermes API DTOs', () {
    final me = Me.fromJson({
      'user_id': 'user_1',
      'email': 'seller@example.com',
      'org_id': 'org_1',
      'org_name': 'Sales Team',
      'plan': {
        'code': 'pro',
        'name': 'Pro',
        'monthly_contact_cap': 2000,
        'verified_contacts_used': 25,
        'verified_contacts_remaining': 1975,
        'allows_phone': true,
        'recipes_limit': 999999,
        'ai_mode': 'contact',
        'period_start': '2026-05-01',
        'period_end': '2026-05-31',
      },
    });

    expect(me.plan.code, 'pro');
    expect(me.plan.allowsPhone, isTrue);

    final leads = LeadList.fromJson({
      'next_cursor': '100',
      'items': [
        {
          'id': 'lead_1',
          'job_id': 'job_1',
          'apollo_contact_id': 'apollo_1',
          'first_name': 'Ada',
          'last_name': 'Lovelace',
          'title': 'Founder',
          'company': 'Analytical Engines',
          'website': null,
          'location': 'US',
          'company_size': '11-50',
          'verified_email_bool': true,
          'verified_phone_bool': false,
          'email': 'ada@example.com',
          'phone': null,
          'score_int': 94,
          'tags_json': ['Software'],
          'ai_json': {'hook': 'growth'},
        }
      ],
    });

    expect(leads.nextCursor, '100');
    expect(leads.items.single.name, 'Ada Lovelace');
    expect(leads.items.single.email, 'ada@example.com');
  });
}
