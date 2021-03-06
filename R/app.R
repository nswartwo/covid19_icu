


####################

server <- function(input, output, session) {
    observe({
        updateSliderInput(session, "floorcapramp", max=input$time)
        updateSliderInput(session, "icucapramp", max=input$time)

        if(input$floorcaptarget < input$floorcap) {
          updateSliderInput(session, "floorcaptarget", value=input$floorcap)
        }
        if (input$icucaptarget < input$icucap) {
          updateSliderInput(session, "icucaptarget", value=input$icucap)
        }
        
      })
  output$hospitalPlot <- renderPlot({
    # put slider control values here as arguments
    plots<- plot_hospital(initial_report=input$initrep,
                  final_report=input$finalrep,
                  L=input$floorcap,
                  M=input$icucap,
                  distribution=input$distrib,
                  t= input$time,
                  chi_C=1/input$avgicudischargetime,
                  chi_L=1/input$avgfloordischargetime,
                  growth_rate=log(2)/(input$doubling_time),
            			mu_C1 = input$ICUdeath_young,
            			mu_C2 = input$ICUdeath_medium,
            			mu_C3 = input$ICUdeath_old,
            			rampslope = input$rampslope,
            			Cinit = input$Cinit,
            			Finit = input$Finit,
            			Lfinal=input$floorcaptarget,
            			Lramp=input$floorcapramp,
            			Mfinal=input$icucaptarget,
            			Mramp=input$icucapramp,
                  doprotocols=input$doprotocols
			
			)


    plot_grid(plots[[1]], plots[[2]],plots[[3]],plots[[4]], nrow=2, ncol=2, labels=c('A', 'B', 'C', 'D'), align="hv")

  })

}

####################


generate_ui <- function() {
fluidPage(theme=shinytheme("simplex"),
 titlePanel("COVID-19 Hospital Capacity Model"),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Scenario", fluid=TRUE,
          includeMarkdown(system.file("content/instructions.md", package='covid19icu')),
          h4("Scenario:"),
          sliderInput("time", "Time Horizon (days)",     min=1, max=60, value=30),
          radioButtons("distrib",                     "Infection curve",
                       c("Exponential"="exponential",
                         "Linear"="ramp",
                         "Saturated"="logistic",
                         "Flat"="uniform"),
                       inline=TRUE,
                       selected="exponential"),
          sliderInput("initrep", "Initial cases per day", min=1, max=1e3, value=50),
          conditionalPanel(
            condition = "input.distrib=='geometric'||input.distrib=='logistic'",
            sliderInput("finalrep", "Peak number of cases", min=1, max=3000, value=1000)
            ),
	conditionalPanel(
            condition = "input.distrib=='ramp'",
            sliderInput("rampslope", "Rate of increase in new cases per day", min=0, max=5, value=1.2, step = .1)
            ),
          conditionalPanel(
            condition = "input.distrib == 'exponential'",
            sliderInput("doubling_time", "Doubling time (days)", min=2, max=28, value=14)
            ),

        ),
        tabPanel("Capacity", fluid=TRUE,
		      includeMarkdown(system.file("content/capacity.md", package='covid19icu')),

          	
		sliderInput("icucap", "ICU capacity",     min=0, max=3000, value=50),
		sliderInput("floorcap", "Initial floor capacity", min=0, max=15000, value=100),
		sliderInput("Cinit", "% of ICU capacity occupied at time 0",     min=0, max=100, value=12),
		sliderInput("Finit", "% of floor capacity occupied at time 0",     min=0, max=100, value=56)),
        tabPanel("Strategy", fluid=TRUE,
          includeMarkdown(system.file("content/protocols.md", package='covid19icu')),
          radioButtons("doprotocols", "Capacity expansion strategy",
                       c("Off"=0, "On"=1),
                       inline=TRUE,
                       selected=0),
          conditionalPanel(
            condition = "input.doprotocols==1",
            sliderInput("icucaptarget",  "Target ICU capacity", min=0, max=3000, value=50),
            sliderInput("icucapramp",  "ICU capacity scale-up (days)", min=0, max=30, value=c(10,20)),
            sliderInput("floorcaptarget",  "Target floor capacity", min=0, max=15000, value=100),
            sliderInput("floorcapramp",  "Floor capacity scale-up (days)", min=0, max=30, value=c(10,20))
          )),
          
        tabPanel("Parameters", fluid=TRUE,
          includeMarkdown(system.file("content/parameters.md", package='covid19icu')),
          sliderInput("avgfloordischargetime", "Average time on floor", min=0, max=25, value=7),
          sliderInput("avgicudischargetime", "Average time in ICU",     min=0, max=25, value=10),
		sliderInput("ICUdeath_young", "Death rate in ICU (<18 years)",     min=0, max=1, value=.1),
		sliderInput("ICUdeath_medium", "Death rate in ICU (18-64 years)",     min=0, max=1, value=.1),
		sliderInput("ICUdeath_old", "Death rate in ICU (65+ years)",     min=0, max=1, value=.1),
        )),width=4),
    mainPanel(
    tabsetPanel(
       tabPanel("Plots", fluid=TRUE,
         plotOutput("hospitalPlot",height="700px")
       ), 
       
    tabPanel("About", fluid=TRUE,
       includeMarkdown(system.file("content/queue_graphic.md", package='covid19icu'))
       ),
    tabPanel("Inputs", fluid=TRUE,
             includeMarkdown(system.file("content/inputs.md", package='covid19icu'))
    ),
    tabPanel("Outputs", fluid=TRUE,
             includeMarkdown(system.file("content/inputs.md", package='covid19icu'))
    )
    )
  )),
  hr(),
  includeMarkdown(system.file("content/footer.md", package='covid19icu'))
)
}

#' @export
runApp <- function() { 
  shinyApp(ui = generate_ui(), server = server)
}
