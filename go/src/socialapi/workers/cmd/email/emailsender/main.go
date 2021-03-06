package main

import (
	"koding/db/mongodb/modelhelper"
	"log"
	"socialapi/config"
	"socialapi/workers/email/emailsender"

	"github.com/koding/eventexporter"
	"github.com/koding/runner"
)

var (
	Name        = "MailSender"
	QueueLength = 1
)

func main() {
	r := runner.New(Name)
	if err := r.Init(); err != nil {
		log.Fatal(err)
	}

	appConfig := config.MustRead(r.Conf.Path)
	modelhelper.Initialize(appConfig.Mongo)
	defer modelhelper.Close()

	segmentExporter := eventexporter.NewSegmentIOExporter(appConfig.Segment, QueueLength)
	datadogExporter := eventexporter.NewDatadogExporter(r.DogStatsD)

	// TODO
	// we are gonna add this line into the multiexporter
	// firstly, we need to make sure our json data satisfy druid's data specs
	// druidExporter := eventexporter.NewDruidExporter(appConfig.DruidHost)
	// exporter := eventexporter.NewMultiExporter(segmentExporter, datadogExporter, druidExporter)

	exporter := eventexporter.NewMultiExporter(segmentExporter, datadogExporter)

	constructor := emailsender.New(exporter, r.Log, appConfig)
	r.ShutdownHandler = constructor.Close

	r.SetContext(constructor)

	r.Register(emailsender.Mail{}).On(emailsender.SendEmailEventName).Handle((*emailsender.Controller).Process)

	r.Listen()
	r.Wait()
}
