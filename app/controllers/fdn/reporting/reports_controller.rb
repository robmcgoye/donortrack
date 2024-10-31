class Fdn::Reporting::ReportsController < Fdn::BaseController
  def dashboard
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "dashboard")
    ]
  end

  def organization_list
    set_organization_filter_params
    @organizations = OrganizationsFilter.new.process_request(@foundation.organizations, @query, @by, (@dir == 1 ? @dir = 2 : @dir = 1))
    pdf = generate_pdf("Organization List", nil, "Portrait", "fdn/reporting/organizations/list")
    send_data(pdf, filename: "organization_list", type: "application/pdf", disposition: :inline)
  end

  def get_commitment
  end

  def get_contribution
  end

  def show_contribution
    contribution_report_form = ContributionReportForm.new(contribution_params)
    @start_at = Date.parse(contribution_report_form.starting_date)
    @end_at = Date.parse(contribution_report_form.ending_date)
    if contribution_report_form.types.include?("0")
      org_ids = @foundation.organization_ids
    else
      org_ids = @foundation.organizations.types(contribution_report_form.types)
    end
    @contributions = Contribution.organization_contributions(org_ids).transactions_during(@start_at, @end_at)
    if !contribution_report_form.funds.include?("0")
      @contributions = @contributions.funds(contribution_report_form.funds)
    end
    if !contribution_report_form.donors.include?("0")
      @contributions = @contributions.donors(contribution_report_form.donors)
    end
    @contributions = @contributions.sort_date_up
    pdf = generate_pdf("Contributions", "fdn/reporting/contributions/header", "Portrait", "fdn/reporting/contributions/summary")
    send_data(pdf, filename: "contribution_report", type: "application/pdf", disposition: :inline)
  end

  def show_commitment
    commitment_report_form = CommitmentReportForm.new(commitment_params)
    if commitment_report_form.state == "open" && commitment_report_form.sort == "alpha"
      @commitments = Commitment.organization_commitments(@foundation.organization_ids).not_completed.sort_organization_up
    elsif commitment_report_form.state == "open" && commitment_report_form.sort == "date"
      @commitments = Commitment.organization_commitments(@foundation.organization_ids).not_completed.sort_start_date_up
    elsif commitment_report_form.state == "closed" && commitment_report_form.sort == "date"
      @commitments = Commitment.organization_commitments(@foundation.organization_ids).completed.sort_start_date_up
    else
      @commitments = Commitment.organization_commitments(@foundation.organization_ids).completed.sort_organization_up
    end
    if commitment_report_form.format == "detailed"
      additional_header = nil
      template = "fdn/reporting/commitments/detailed"
      orientation = "Portrait"
    else
      additional_header = "fdn/reporting/commitments/summary_header"
      template = "fdn/reporting/commitments/summary"
      orientation = "Landscape"
    end
    pdf = generate_pdf("Commitments", additional_header, orientation, template)
    send_data(pdf, filename: "commitment_report", type: "application/pdf", disposition: :inline)
  end

  private

  def commitment_params
    params.require(:commitment_report_form).permit(:format, :state, :sort)
  end

  def contribution_params
    params.require(:contribution_report_form).permit(:starting_date, :ending_date, funds: [], donors: [], types: [])
  end

  def generate_pdf(title, additional_header, orientation, template)
    WickedPdf.new.pdf_from_string(
      render_to_string(template: template, formats: [ :html ], layout: "pdf"),
      # margin: { top: 10, bottom: 10, left: 10, right: 10 },
      header: { content: render_to_string(template: "shared/pdf/header",
                  formats: [ :html ],
                  layout: "pdf_section",
                  locals: { title: title, additional_header: additional_header })
              },
      footer: { content: render_to_string(template: "shared/pdf/footer",
                  formats: [ :html ],
                  layout: "pdf_section")
                #  right: "[page] of [topage]"
              },
              orientation: orientation
    )
  end
end
