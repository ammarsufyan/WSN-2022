# Create a Simulator
set ns [new Simulator]

# Create trace object
set traceku [open out1.tr w]
$ns trace-all $traceku
# Create a NAM trace file
set NAMku [open out1.nam w]
$ns namtrace-all $NAMku

# Define a finish procedure
proc finish {} {
 global ns traceku NAMku
 $ns flush-trace
 close $traceku
 close $NAMku
 puts "running nam..."
 exec nam out1.nam &
 exit 0
} 

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node] 

# Connect each node with duplex link
$ns duplex-link $n0 $n2 1Mb 5ms DropTail
$ns duplex-link $n1 $n2 1Mb 5ms DropTail
$ns duplex-link $n2 $n4 5Mb 10ms DropTail
$ns duplex-link $n2 $n3 5Mb 10ms DropTail
$ns simplex-link $n3 $n4 0.5Mb 15ms DropTail
$ns queue-limit $n2 $n3 4

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient left-up
$ns duplex-link-op $n1 $n2 orient left-down
$ns duplex-link-op $n2 $n4 orient right
$ns duplex-link-op $n2 $n3 orient right-down

# Create a UDP flow from n0 to n3
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 1

# Attach CBR source to the UDP flow
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 500
$cbr set interval_ 0.005

# Create a TCP flow from n1 to n4
set tcp [new Agent/TCP]
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 2

# Attach FTP source to the TCP flow
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Schedule Events
$ns at 0.5 "$ftp start"
$ns at 2.0 "$cbr start"
$ns at 4.5 "$ftp stop"
$ns at 5.0 "$cbr stop" 

# Put the information to the CLI editor
puts [$cbr set packetSize_]
puts [$cbr set interval_]

$ns at 6.0 "finish"
$ns run
