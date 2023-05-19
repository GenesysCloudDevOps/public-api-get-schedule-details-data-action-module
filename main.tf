resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "properties" = {
            "searchAttribute" = {
                "description" = "The name of the Schedule matching exactly or with a wildcard * character",
                "title" = "Schedule Name",
                "type" = "string"
            }
        },
        "required" = [
            "searchAttribute"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "properties" = {
            "RRule" = {
                "description" = "",
                "title" = "Rrule",
                "type" = "string"
            },
            "ScheduleEnd" = {
                "description" = "",
                "title" = "End",
                "type" = "string"
            },
            "ScheduleStart" = {
                "description" = "",
                "title" = "Start",
                "type" = "string"
            },
            "State" = {
                "description" = "",
                "title" = "State",
                "type" = "string"
            }
        },
        "title" = "Open and Closed Times",
        "type" = "object"
    })
    
    config_request {
        request_template     = "$${input.rawRequest}"
        request_type         = "GET"
        request_url_template = "/api/v2/architect/schedules?name=$esc.url($${input.searchAttribute})"
        headers = {
			UserAgent = "PureCloudIntegrations/1.0"
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\"ScheduleStart\": $${successTemplateUtils.firstFromArray($${ScheduleStart})}, \"ScheduleEnd\": $${successTemplateUtils.firstFromArray($${ScheduleEnd})}, \"State\": $${successTemplateUtils.firstFromArray($${State})}, \"RRule\": $${successTemplateUtils.firstFromArray($${RRule})}}"
        translation_map = { 
			ScheduleEnd = "$.entities[?(@.id != '')].end"
			RRule = "$.entities[?(@.id != '')].rrule"
			ScheduleStart = "$.entities[?(@.id != '')].start"
			State = "$.entities[?(@.id != '')].state"
		}
               
    }
}