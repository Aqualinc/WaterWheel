library(shiny)
library(ggplot2)
library(markdown)
source("R_code/Water_wheel_diagram.R")

#load in the attribute and criteria data
load("Data/Takaka.RData")

#Save a copy of the criteria file so it is available to users
write.csv(criteria,file="www/criteria.csv")

#Get the list of unique values
valuesSet <- unique(criteria[1])
rownames(valuesSet)<- seq_len(nrow(valuesSet))

#Rshiny server function
server <- function(input, output) {
        
    #Get the list of scenarios
    scenarios <- reactive({
      labels=names(attributes)
      items=seq(length(labels))
      names(items)=labels
      as.list(items)      
    })
    if(is.null(scenarios)){return(1)}
    
    #create a "select scenario" input user interface
    output$scenario1 <- renderUI({selectInput("scenario1V2", "Scenarios:",choices=scenarios())})
    output$scenario2 <- renderUI({selectInput("scenario2V2", "Scenarios:",choices=scenarios())})
    
    userCriteria <- reactive({
      inFile <- input$file1
      if (is.null(inFile))
        return(criteria)
      criteriaData <- read.csv(inFile$datapath, header = TRUE, row.names = 1,sep = ",", quote = "\"'")
      return(criteriaData)
    })
    
    
    #plot the wheels , one for each of the two seleted scenarios. They update when the "attributesUpdate" action button is pressed or when the
    #scenario selection is changed. Note that the attribute check boxes are wrapped in the "isolate" function to avoid updating everytime any
    #one of them is changed.
    output$WheelOfWater <- renderPlot({input$attributesUpdate
                                       outputOptions(output,"WheelOfWater",suspendWhenHidden=FALSE)
                                       selected_scenario   <-as.numeric(input$scenario1V2)
                                       if(length(selected_scenario)==0){selected_scenario=1}           #set the initial scenario to the first one. This is necesary to avoid an error message while the shinyapp waits for the reactive "scenarios()" function to complete
                                       selected_attributes <-isolate(as.numeric(c(input$attributes1,input$attributes2,input$attributes3,input$attributes4,input$attributes5,input$attributes6)))
                                       wheelValues         <-t(as.matrix(cbind(attribute=rownames(userCriteria()[selected_attributes,]),
                                                                               userCriteria()[selected_attributes,],value=attributes[selected_attributes,selected_scenario]),
                                                                         length(selected_attributes),ncol(userCriteria())+2))
                                       WaterWheelDiagram(wheelValues)
    })
    output$WheelOfWater2 <- renderPlot({input$attributesUpdate
                                        outputOptions(output,"WheelOfWater",suspendWhenHidden=FALSE)
                                        selected_scenario   <-as.numeric(input$scenario2V2)
                                        if(length(selected_scenario)==0){selected_scenario=1}           #set the initial scenario to the first one. This is necesary to avoid an error message while the shinyapp waits for the reactive "scenarios()" function to complete
                                        selected_attributes   <-isolate(as.numeric(c(input$attributes1,input$attributes2,input$attributes3,input$attributes4,input$attributes5,input$attributes6)))
                                        wheelValues         <-t(as.matrix(cbind(attribute=rownames(userCriteria()[selected_attributes,]),
                                                                                userCriteria()[selected_attributes,],value=attributes[selected_attributes,selected_scenario]),
                                                                          length(selected_attributes),ncol(userCriteria())+2))
                                        WaterWheelDiagram(wheelValues)
    })
    output$CriteriaTable <- renderDataTable({criteria<-cbind(attributes=rownames(criteria),criteria) 
                                             criteria})
    output$attributeTable <- renderDataTable({attribute<-cbind(attributes=rownames(attributes),attributes) 
                                              attribute})
    output$criteria2 <- renderDataTable({usercriteria<-cbind(attributes=rownames(userCriteria()),userCriteria())
                                         usercriteria})
      } #end of the Rshiny server function


#Set up the "Update Button" ready for use in the ui function below
update.Button = do.call(actionButton,as.list(c("attributesUpdate","Update")))

#Set up the Attribute check boxes and labels and groupings by "value" for use in the ui below
attribute.rows.input <- c(list(h3("Attributes"),update.Button),lapply(1:nrow(valuesSet), function(i) {column(12,checkboxGroupInput(paste0("attributes",i),label= h4(valuesSet[i,]),
                                                                                                 choices=as.list(setNames(which(criteria[1]==valuesSet[i,]),rownames(criteria[criteria[1]==valuesSet[i,],]))),
                                                                                                 selected=which(criteria[1]==valuesSet[i,])))}))
attribute.rows = do.call(fluidRow, attribute.rows.input)

#Rshiny ui function
 ui <- fluidPage(
    titlePanel(h2("Takaka FLAG Water Wheel")),
    sidebarLayout(
      sidebarPanel(width=2,attribute.rows,
       
      p("Prepared for the",
        a("Wheel of Water",href="http://https://wheelofwater.wordpress.com"),
        "research project funded by the Ministry of Business, Innovation and Employment."),
      p("Interface design by Tim Kerr"),
      p("Scenario modelling by Julian Weir"),
      a(img(src="logo.gif",height="4%",width="100%"),href="http://www.aqualinc.com") #Note that the image will not show on your browser with Chrome because of "security" issues
      ),
      mainPanel(width=10,navbarPage("",
                                    tabPanel("Wheel of Water diagram",
                                             fluidPage(style="width:100%",column(6,style="overflow-x:scroll; max-width=800",uiOutput("scenario1"),
                                                                                 plotOutput("WheelOfWater",height=700,width=700)),
                                                       column(6,style="overflow-x:scroll; max-width=800",uiOutput("scenario2"),
                                                              plotOutput("WheelOfWater2", height=700, width=700)) 
                                             )),
                                    #tabPanel("Criteria",
                                    #            fluidRow(dataTableOutput(outputId="CriteriaTable"))
                                    #            ),
                                    tabPanel("Attributes",
                                             fluidRow(dataTableOutput(outputId="attributeTable"))
                                    ),
                                    tabPanel("Criteria",
                                             fileInput('file1', 'Choose Criteria file to upload',
                                                       accept = c('text/csv','text/comma-separated-values','.csv'
                                                       )
                                             ),
                                             p('To ensure correct criteria file format,',
                                               'you can first download the sample',
                                               a(href = 'criteria.csv', 'criteria.csv'),
                                               'file, edit it as required, and then upload it.'
                                             ),
                                             dataTableOutput(outputId="criteria2")
                                             
                                    ),
                                    tabPanel("How it works",
                                             fluidRow(
                                               column(9, 
                                                      includeMarkdown("www/Quality AttributesV4.md")
                                               )
                                             )
                                    )
      )
      )
    )
  )
 
 shinyApp(ui = ui, server = server)
