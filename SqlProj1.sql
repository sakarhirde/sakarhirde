select
    ati.ticket_id as ticket_id,
    ati.TEMP_ID as unique_t_id,
    ati.STORE_ID as ticket_store_id,
    ati.cust_ticket_number as cust_tick_number,
    asi.company_name as store_name,
    asr.store_id as store_id,
    aci.company_name as client,
    abi.company_name as brand,

    ats.cat_name as ticket_status,       /* problem increase 5.7k to 7.8k*/
    stt.type_name as ticket_type,        /* problem increase 5.7k to 7.8k*/
    atf.DATE  as last_follow_up_date,

    (case
        when atf.details is not null then atf.details
        else 'No followup message'
    end) as last_follow_up_message,
    timestampdiff(month , ati.ENTRYTIME, date_add(now(), interval 330 minute)) as ticket_age,
    timestampdiff(month , atf.date, date_add(now(), interval 330 minute)) as followup_age,
    ati.call_title as call_title,
    (case
        when timestampdiff(month , ati.ENTRYTIME, date_add(now(), interval 330 minute)) between 0 and 3 then '0-3'
        when timestampdiff(month , ati.ENTRYTIME, date_add(now(), interval 330 minute)) between 3 and 7 then '3-7'
        when timestampdiff(month , ati.ENTRYTIME, date_add(now(), interval 330 minute)) >7 then '7+'
        else 'No information'
    end) as ticket_age_group

from adm_ticket_info ati
     left join adm_store_regdetails asr on ati.temp_ID = asr.ID
     left join adm_store_info asi on asi.ADMIN_ID = asr.ID

     left join adm_brand_regdetails abr on abr.ID = asr.BRAND_ID /*65 vs 67*/
     left join adm_brand_info abi on abr.ID = abi.ADMIN_ID

     left join adm_client_regdetails acr on acr.ID = abr.COMPANY_ID /*checked*/
     left join adm_client_info aci on aci.ADMIN_ID = acr.ID

     left join adm_ticket_status ats on ats.CAT_ID = ati.STATUS /*checked*/


     left join smr_ticket_type stt on stt.TEMP_ID = ati.TICKET_TYPE

     left join (select * from adm_ticket_followups where F_ID in (
                select max(F_ID) from adm_ticket_followups group by TICKET_ID)) atf on atf.TICKET_ID = ati.TEMP_ID;
